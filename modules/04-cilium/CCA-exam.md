# CCA Exam Notes

Lernnotizen für die Cilium Certified Associate (CCA) Prüfung.
Wird nach jedem abgeschlossenen Tag ergänzt.

---

## Ch3 — Cilium Basics (Tag 31)

### Health Check
- Erster Befehl bei Problemen: `cilium status` — zeigt Agent, Operator, Hubble, Endpoint-Anzahl

### Endpoints
- Endpoint = ein Pod (+ System-Endpoints wie Host, Health)
- `ready` = eBPF-Programme geladen, Identity berechnet, Policy aktiv
- `not-ready` = Cilium verarbeitet noch — Policy greift noch nicht
- Ein Pod kann K8s `Running` sein aber Cilium-Endpoint noch `not-ready`

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list -o json
```

> `cilium-dbg` = Binary im Agent-Pod (ab v1.14). `cilium` = externes CLI-Tool.

### Identity
- Identity = numerische ID, berechnet aus **allen** Labels (Custom + System + Namespace)
- Pods mit identischen Custom-Labels aber unterschiedlichen Namespaces → **unterschiedliche Identities**
- Policy-Enforcement läuft über Identity, nicht über IP → stabil bei Pod-Neustart

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg identity get <ID>
```

### CiliumNetworkPolicy
- `endpointSelector` = Perspektive (auf wen die Policy zutrifft)
- Von dort aus wird Ingress/Egress definiert
- Sobald eine `ingress`-Regel existiert → automatischer Ingress Default-Deny

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: frontend
```

### Traffic-Verhalten bei Policy-Drop
- Geblockte Pakete → **Timeout** (eBPF drop, kein TCP RST)
- Connection Refused → Host erreichbar, Port/App-Problem (kein Policy-Problem)

### Hubble
- Zeigt **Flow-Events** (nicht rohe Pakete): Pod-Namen, Policy-Entscheidung, L7-Infos
- `hubble observe --follow` — parallel beim Testen laufen lassen

---

## Ch4 — IPAM Part 1 (Tag 32)

### Grundlagen
- Pod-IP-Vergabe = Aufgabe des **CNI-Plugins** (nicht kube-proxy)
- kube-proxy = Service-Routing (iptables/ipvs)
- Ablauf: Pod startet → kubelet ruft CNI auf → CNI fragt IPAM → Pod bekommt IP

### IPAM-Modi

| Modus | Verwaltung | Speicherort | Geeignet für |
|-------|-----------|-------------|--------------|
| `kubernetes` | K8s verwaltet podCIDR | `spec.podCIDR` am Node-Objekt | Kleine Cluster, einfache Setups, CNI-Migration |
| `cluster-scope` | Cilium Operator verwaltet zentralen Pool | `CiliumNode` CRD (eines pro Node) | Große Cluster, IP-Effizienz |

### kubernetes-Modus (host-scope)
- K8s weist jedem Node einen festen CIDR-Block zu (z.B. `10.0.1.0/24`)
- Cilium liest `spec.podCIDR` und vergibt IPs daraus
- Vorab-Reservierung des gesamten Blocks — auch wenn nur wenige Pods laufen

```bash
kubectl get node <node-name> -o jsonpath='{.spec.podCIDR}'
```

### cluster-scope
- Cilium Operator verwaltet den gesamten Cluster-CIDR zentral
- IPs werden **on-demand** vergeben — kein vorab reservierter Block pro Node
- Speicherort: `CiliumNode` Custom Resources

```bash
kubectl get ciliumnodes
kubectl get ciliumnode <node-name> -o yaml
```

> Für RKE2 + Cilium: cluster-scope ist der empfohlene Default.

---

## Ch4 — IPAM Part 2 (Tag 33)

### Multi-Pool IPAM
- Mehrere `CiliumPodIPPool` CRDs — getrennte IP-Bereiche pro Tenant/Workload
- Zuweisung via Annotation `ipam.cilium.io/ip-pool` auf Namespace (oder Pod)
- IPAM ist eine **Day-0-Entscheidung** — Wechsel des Modus erfordert Cluster-Neuaufbau (alle Pod-IPs gehen verloren)

```bash
kubectl get ciliumpodippools
kubectl get ciliumnodes -o json | jq '.items[] | {node: .metadata.name, pools: .spec.ipam.pools}'
```

### Block-Zuteilung
- `maskSize` = Granularität der Blöcke pro Node (z.B. /27 = 32 Adressen)
- **Kein Hard-Limit**: Ist ein Block voll, bekommt der Node dynamisch einen weiteren
- `requested.needed` in `CiliumNode` = wie viele Adressen der Node aktuell anfordert
- Ein Node kann gleichzeitig Blöcke aus **mehreren Pools** halten (z.B. `default` + `acme-pool`)

### AWS ENI IPAM (nur Konzept)
- Cilium delegiert IP-Verwaltung an die EC2 API — IPs sind physisch an ENIs gebunden
- Exam-relevant, im RZ (on-prem) nicht

### Dual-Stack (nur Konzept)
- IPv4 + IPv6 gleichzeitig: `ipFamily: dual` in Kind + `ipv6.enabled: true` in Cilium
- Voraussetzung: Kubernetes selbst muss dual-stack enabled sein (≥ v1.20)
- Exam-relevant, im RZ ohne IPv6 nicht

---

## Troubleshooting-Fall: GENEVE auf Docker Desktop (Tag 34)

**Symptom:** `cilium status` → Endpoints `not-ready` auf allen Nodes, `cilium-health-ep` Timeouts, BPF-Compile-Fehler (`macro redefined`) in den Logs.

**Debugging-Kette (von außen nach innen):**
1. `cilium status` → Warnings/Errors lokalisieren
2. Agent-Logs nach `level=warn|error` filtern → BPF-Compile-Fehler gefunden (sah wie Root Cause aus)
3. Tiefer graben → `Failed to initialize datapath ... creating device cilium_geneve: invalid argument` im 10s-Takt
4. Echte Root Cause: Kernel der Docker-Desktop-VM kann kein GENEVE-Device anlegen → Datapath-Init scheitert → node_config.h wird nie gerendert → Compile-Fehler nur Folgesymptom

**Die 4 Learnings:**
1. **Nicht beim ersten Fehler stehenbleiben** — dem Fehler bis zur untersten Schicht folgen, bevor man fixt
2. **Retry-Loop im festen Takt (`retryDelay=10s`) = Umgebungsproblem** — kein Versions-Bump hilft (empirisch bewiesen: 1.18.2 → 1.18.10 → 1.19.4, dreimal derselbe Fehler). CNI-Datapath hängt am Kernel
3. **Config geändert ≠ Config aktiv** — `helm upgrade` ändert nur die ConfigMap, der Agent liest sie nur beim Start → `rollout restart` nötig. Pod-Age gegen Änderungszeitpunkt prüfen; `config-drift-checker` loggt `Mismatch found`
4. **Konzept vor Werkzeug** — GENEVE blockiert → VXLAN-Fallback, Routing-Konzept identisch (Overlay, ipcache, keine via-Routen)

→ Ausführlich im [Troubleshooting-Playbook](cheatsheets/troubleshooting-playbook.md)

---

## Ch5 — Routing (Tag 34)

### Die zwei Routing-Modi

| | Native Routing | Tunnel-Modus (Encapsulation) |
|---|---|---|
| Paket auf dem Draht | Pod-IPs direkt ("nackt") | Outer-Paket mit **Node-IPs**, Inner mit Pod-IPs |
| Kernel-Routing-Tabelle | via-Routen zu **fremden Node-IPs** (`dev eth0`) | nur **Trichter-Routen** auf eigene cilium_host-IP |
| Routing-Intelligenz | Kernel-Routing-Tabelle | **eBPF ipcache-Map** |
| Underlay muss | Pod-CIDRs kennen (L2 + autoDirectNodeRoutes oder BGP) | nur Node-IPs kennen |
| Tunnel-Device | — | `cilium_vxlan` / `cilium_geneve` |

Merksatz: *Native legt die Intelligenz in die Kernel-Routing-Tabelle, Tunneling in die eBPF-Maps.*

### Node-Routes (Native Routing)
- **Eine Route pro Remote-CIDR-Block pro Node** — nicht pro Pod
- Gleiche L2-Domain: `autoDirectNodeRoutes: true` — Agent schreibt Routen via netlink
- Geroutetes Underlay: Pod-CIDRs per **BGP** announcen
- Routen schreibt der **Agent (Control Plane)**, nicht eBPF — eBPF ist Data Plane (pro Paket am tc-Hook)

### VXLAN vs. GENEVE
| | VXLAN (RFC 7348) | GENEVE (RFC 8926) |
|---|---|---|
| Header | fix, 8 Byte | **erweiterbar (TLV-Options)** |
| UDP-Port (Cilium/Linux) | 8472 | 6081 |
| Besonderheit | Default bei Cilium | nötig für **DSR** (Metadaten im Header, → Ch8) |

### ipcache (eBPF-Map)
- **Key = Pod-IP/Prefix, Value = `tunnelendpoint` (Node-IP) + `identity`** — Routing + Security in einem Lookup
- `flags=hastunnel` = verpacken Richtung Node-eth0-IP; `tunnelendpoint=0.0.0.0` = lokal/direkt
- Ein Node tunnelt nie zu sich selbst → Einträge ohne tunnelendpoint verraten den lokalen Pod-CIDR
- Well-Known-Identities: `1`=host, `2`=world, `4`=health, `6`=remote-node

```bash
cilium config view | grep -E "routing|tunnel"
kubectl -n kube-system exec ds/cilium -- cilium-dbg bpf ipcache list
```

### Diagnose-Schnellcheck (ohne Config)
- `ip route`: `via <fremde Node-IP> dev eth0` = Native · `via <eigene IP> dev cilium_host` = Tunnel
- `ip link`: `cilium_vxlan`/`cilium_geneve` vorhanden = Tunnel-Modus (kein `@` = kein veth)
- tcpdump Tunnel: `tcpdump -i eth0 udp port 8472` (Outer) bzw. `-i cilium_vxlan` (ausgepackt)

### RZ-Transfer (Frage ans Platform-Team)
> Fahren wir auf RKE2 Native Routing oder Tunneling — und falls Tunnel: VXLAN oder GENEVE?
> Falls Native: announcen wir die Pod-CIDRs per BGP oder reicht `autoDirectNodeRoutes` (gleiche L2-Domain)?
> *(Antwort einarbeiten sobald verfügbar — `cilium config view | grep -E "routing|tunnel"`)*
