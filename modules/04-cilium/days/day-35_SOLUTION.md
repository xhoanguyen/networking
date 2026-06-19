# Tag 35 — Lösung: Ch6 kube-proxy Replacement Part 1

---

## Aufgabe 1 — Ist-Zustand: läuft kube-proxy noch?

```bash
kubectl -n kube-system get ds kube-proxy
kubectl -n kube-system get pods -l k8s-app=kube-proxy -o wide
```

1. kube-proxy läuft als **DaemonSet** → ein Pod **pro Node**.
2. Bei 1 Control-Plane + 2 Workern → **3 Pods**. Genau deshalb DaemonSet: kube-proxy muss auf
   *jedem* Node die iptables-Regeln schreiben, weil jedes Service-Lookup lokal auf dem Node
   passiert, wo der Client-Pod läuft.
3. `cilium status | grep KubeProxyReplacement`:
   ```
   KubeProxyReplacement:   False
   ```
   `False` = Cilium ersetzt kube-proxy **nicht**, der klassische kube-proxy macht das
   Service-LB via iptables. Cilium kümmert sich nur ums Pod-Networking.

> Merke: `False` heißt nicht "kaputt" — es heißt "kube-proxy ist noch der Chef über Services".

---

## Aufgabe 2 — Cluster ohne kube-proxy neu bauen

**1. kind-Config — kube-proxy abschalten:**

```yaml
# kind-no-kubeproxy.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true     # kein kindnet — Cilium übernimmt
  kubeProxyMode: "none"       # ← DAS verhindert den kube-proxy-Rollout
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

**2. Cluster + Cilium mit Replacement:**

```bash
kind delete cluster --name cilium-lab
kind create cluster --name cilium-lab --config kind-no-kubeproxy.yaml

helm install cilium cilium/cilium --version 1.19.4 --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=cilium-lab-control-plane \
  --set k8sServicePort=6443 \
  --set routingMode=tunnel --set tunnelProtocol=vxlan
```

Der entscheidende Value: **`kubeProxyReplacement=true`**.
(Ältere Cilium-Versionen kannten `strict`/`partial`/`disabled` — ab 1.14 nur noch `true`/`false`.)

**3. Was Cilium jetzt zusätzlich braucht — das Henne-Ei-Problem:**

Ohne kube-proxy gibt es niemanden, der die `kubernetes`-ClusterIP (`10.96.0.1:443`) auf den
echten API-Server übersetzt. Der Cilium-Agent muss aber den API-Server erreichen, **bevor** er
selbst die Service-Übersetzung aufgebaut hat. Henne-Ei!

Deshalb gibst du ihm die **echte API-Server-Adresse direkt** mit:
- `k8sServiceHost` = API-Server-Host (bei kind der Control-Plane-Container-Name)
- `k8sServicePort` = `6443`

Damit umgeht der Agent die ClusterIP beim Bootstrap und redet direkt mit dem API-Server.

---

## Aufgabe 3 — Beweis auf drei Ebenen

**1. Workload-Ebene — DaemonSet ist weg:**

```bash
kubectl -n kube-system get ds kube-proxy
# Error from server (NotFound): daemonsets.apps "kube-proxy" not found
```

**2. Kernel-Ebene — keine KUBE-SVC-Ketten:**

```bash
docker exec -it cilium-lab-worker iptables-save | grep -c KUBE-SVC
# 0
```

`0` ist der Beweis. Mit kube-proxy stünde hier pro Service eine `KUBE-SVC-*`-Kette (+ pro Backend
eine `KUBE-SEP-*`-Kette) — die lineare Liste, die schlecht skaliert. Bei Cilium liegt das
Service-Mapping stattdessen in **eBPF-Maps**, nicht in iptables.

**3. Cilium-Ebene:**

```bash
cilium status | grep KubeProxyReplacement
# KubeProxyReplacement:   True   [eth0   172.18.0.x ...]
```

`True` = Cilium macht jetzt das komplette Service-LB. Die Devices in Klammern (`eth0`) sind die
Interfaces, an denen Cilium den **tc/XDP-Hook** für north-south-Traffic (NodePort) hängt — dort
kommen externe Pakete rein.

---

## Aufgabe 4 — ClusterIP-Service in der eBPF-Map

```bash
kubectl create deployment web --image=nginx --replicas=2
kubectl expose deployment web --port=80 --type=ClusterIP
kubectl -n kube-system exec ds/cilium -- cilium-dbg service list
```

```
ID   Frontend            Service Type   Backend
12   10.96.231.50:80     ClusterIP      1 => 10.0.1.20:80 (active)
                                        2 => 10.0.2.31:80 (active)
```

1. **Frontend = die ClusterIP** des Services (`10.96.231.50:80`). **Backends = die echten
   Pod-IPs** der zwei nginx-Pods.
2. 2 Replicas → **2 Backend-Einträge**. (Die Pod-IPs liegen in verschiedenen Pod-CIDRs, weil die
   Pods auf verschiedenen Nodes landen — vgl. Tag 32/33 IPAM.)
3. Nach `kubectl scale deployment web --replicas=4` → **4 aktive Backends** in der Map.
   Aktualisiert hat das der **cilium-agent (Control Plane)**: Er watcht Endpoints/EndpointSlices
   am API-Server und schreibt die eBPF-Service-Map neu. Die **Data Plane** (eBPF-Programm) liest
   diese Map dann bei jedem `connect()` — schreibt sie aber nicht.

> Das ist exakt die kube-proxy-Logik, nur das Ziel ist eine eBPF-Map statt iptables:
> **Agent schreibt, eBPF liest.**

---

## Aufgabe 5 — Hook-Vorhersage

Die einzig richtige Frage: **Wo wird `connect()` aufgerufen?**
Lokaler Pod → **Socket-LB**. Externer Client → **tc/XDP**. Der Backend-Standort ist irrelevant
für den *Hook* (er betrifft nur den Paket-*Pfad*, Achse 2).

| # | Szenario | Hook | Warum |
|---|----------|------|-------|
| a | Pod Node-1 → ClusterIP, Backend Node-1 | **Socket-LB** | `connect()` läuft im lokalen Pod auf Node-1 |
| b | Pod Node-1 → ClusterIP, Backend Node-2 | **Socket-LB** | `connect()` läuft im lokalen Pod auf Node-1 — Backend-Node egal |
| c | Externer Laptop → NodePort, Backend lokal | **tc/XDP** | Client ist extern, kein lokaler `connect()` abzufangen |
| d | Externer Laptop → NodePort, Backend remote | **tc/XDP** | Client ist extern → tc/XDP; danach geht's via Routing/Tunnel zum Remote-Node |

Kernfalle: **a/b haben denselben Hook**, obwohl das Backend mal lokal, mal remote ist. Und **c/d
haben denselben Hook**, obwohl das Backend mal lokal, mal remote ist. Der Hook hängt **nur** am
Client-Standort.

**Bonus — Socket-LB verifizieren (Sollzustand ≠ Istzustand!):**

Der naheliegende Befehl führt hier in die Irre:

```bash
cilium config view | grep -i sock
# bpf-lb-sock   false      ← ConfigMap = deklarierter Sollzustand
```

`bpf-lb-sock: false` heißt **nicht**, dass Socket-LB aus ist. Diese Zeile ist nur der explizite
Override-Knopf, der hier nie gesetzt wurde. Was wirklich läuft, fragst du die **Agent-Runtime**:

```bash
kubectl -n kube-system exec ds/cilium -- cilium-dbg status --verbose
```

```
KubeProxyReplacement Details:
  Status:                True
  Socket LB:             Enabled          ← DAS ist die Wahrheit
  Socket LB Coverage:    Full
  Devices:               eth0 ... (Direct Routing)   ← hier hängt der tc-Hook (north-south)
  XDP Acceleration:      Disabled         ← also tc-Hook, NICHT hardware-XDP
  Mode:                  SNAT
  Backend Selection:     Random
  Services: ClusterIP / NodePort (30000-32767) / LoadBalancer / externalIPs / HostPort  → alle Enabled
```

`Socket LB: Enabled`, `Coverage: Full` = Socket-LB ist für **alle** Pods aktiv. Der Agent leitet
das aus `kubeProxyReplacement=true` ab — unabhängig vom `bpf-lb-sock`-Wert in der ConfigMap.
Damit übersetzt Cilium east-west-Traffic schon beim `connect()` — ohne per-Paket-DNAT.

> **Sollzustand ≠ Istzustand** (dasselbe Muster wie `cilium status` vs. `cilium-dbg status` an
> Tag 35 und `helm upgrade` vs. aktive Config an Tag 34): Wenn deklarierte Config und Runtime sich
> widersprechen, **gewinnt die Runtime**. Zum *Beweisen, was läuft* → immer `cilium-dbg status
> --verbose`, nicht `config view`.

---

## Das Bild — kube-proxy vs. Cilium kube-proxy Replacement

```
  KLASSISCH (kube-proxy)                      CILIUM REPLACEMENT
┌────────────────────────────┐            ┌────────────────────────────┐
│ kube-proxy (Control Plane) │            │ cilium-agent (Control Plane)│
│   watcht API-Server         │            │   watcht API-Server         │
│   schreibt ▼                │            │   schreibt ▼                │
│ ┌────────────────────────┐ │            │ ┌────────────────────────┐ │
│ │ iptables KUBE-SVC-Ketten│ │            │ │ eBPF Service-Map        │ │
│ │ lineare Liste, O(n)     │ │            │ │ Hash-Lookup, O(1)       │ │
│ └────────────────────────┘ │            │ └────────────────────────┘ │
│   liest ▲ (Kernel/netfilter)│            │   liest ▲                   │
│ DNAT pro PAKET + conntrack  │            │ east-west: Socket-LB        │
│                             │            │   → einmal bei connect()    │
│                             │            │ north-south: tc/XDP am eth0 │
└────────────────────────────┘            └────────────────────────────┘
```

**Merk-Anker:**
1. **Beide Welten:** "Agent schreibt, Kernel/eBPF liest" — nur das Ziel unterscheidet sich
   (iptables-Ketten vs. eBPF-Map).
2. **Skalierung:** lineare Liste (O(n) + Full-Reload) → Hash-Map (O(1)).
3. **east-west einmalig:** Socket-LB übersetzt beim `connect()`, danach Null per-Paket-Overhead.
   iptables macht DNAT bei *jedem* Paket.

---

## RZ-Profi-Tipps des Tages

- **`cilium-dbg service list` ist dein `iptables-save | grep KUBE-SVC`** der eBPF-Welt — die
  komplette Service→Backend-Map in einer übersichtlichen Tabelle statt hunderter iptables-Regeln.
- **`KubeProxyReplacement: True [eth0 ...]` lesen:** Die Devices in der Klammer sind genau die
  Interfaces mit tc/XDP-Hook für NodePort. Fehlt dein erwartetes Interface dort, kommt
  north-south-Traffic nicht an — erster Blick beim NodePort-Debugging.
- **Henne-Ei beim kube-proxy-freien Cluster:** Bleibt der cilium-agent in `CrashLoopBackOff` mit
  "connection refused" zur `kubernetes`-ClusterIP, fehlen fast immer `k8sServiceHost`/
  `k8sServicePort`. Der Agent muss den API-Server direkt finden, bevor er Services übersetzen kann.
- **`grep -c` statt `grep`** beim Beweisen von Abwesenheit: `iptables-save | grep -c KUBE-SVC`
  gibt dir direkt die Zahl `0` — schneller als eine leere Ausgabe zu interpretieren.
