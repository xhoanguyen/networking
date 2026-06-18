# Tag 34 — Lösung: Ch5 Routing

---

## Aufgabe 1 — Aktuellen Routing-Modus bestimmen

```bash
cilium config view | grep -E "routing|tunnel"
# routing-mode    native
```

Cilium-Default ist eigentlich **Tunnel-Modus (VXLAN)** — hier lief aber `native`, weil das
chapter04-Values-File (Multi-Pool IPAM) `routingMode: native` + `autoDirectNodeRoutes: true`
gesetzt hatte. Merke: Der aktive Modus kommt aus den Helm-Values, nicht aus dem Default.

---

## Aufgabe 2 — Routen vorhersagen (Native Routing)

Herleitung: **Eine Route pro CIDR-Block pro Remote-Node** — nicht pro Pod!
Die Blöcke stehen in den `CiliumNode` CRs:

```bash
kubectl get ciliumnodes -o json | jq '.items[] | {node: .metadata.name, pools: .spec.ipam.pools}'
```

Die anderen zwei Nodes hielten zusammen 3 Blöcke → **3 via-Routen** erwartet. Verifiziert:

```
10.10.0.0/27  via 172.18.0.2 dev eth0     ← Pod-CIDR-Route (Remote-Node!)
10.10.0.32/27 via 172.18.0.4 dev eth0     ← Pod-CIDR-Route
10.20.0.0/27  via 172.18.0.2 dev eth0     ← Pod-CIDR-Route
default via 172.18.0.1 dev eth0           ← Default
172.18.0.0/16 dev eth0 ...                ← lokal (Underlay)
10.x.x.x dev lxc... / cilium_host         ← lokal (eigene Pods)
```

**Kernmerkmal Native Routing:** via zeigt auf die **eth0-IP eines fremden Nodes** —
der **Kernel** weiß, wo jeder Pod-Block wohnt. Das Underlay muss Pod-CIDRs routen können
(gleiche L2-Domain + `autoDirectNodeRoutes`, oder BGP-Announcement).

Die Routen schreibt der **cilium-agent** (Control Plane) via netlink — nicht eBPF.
eBPF ist Data Plane: verarbeitet Pakete am tc-Hook, pro Paket.

---

## Aufgabe 3 — Umbau auf Tunnel-Modus (+ Troubleshooting-Fall)

```bash
kind delete cluster --name cilium-lab
kind create cluster --name cilium-lab --config chapter05/kind.yaml
helm install cilium cilium/cilium --version 1.19.4 --namespace kube-system \
  --set routingMode=tunnel \
  --set tunnelProtocol=geneve \
  --set ipam.mode=cluster-pool
```

**GENEVE scheiterte** — Endpoints not-ready, BPF-Compile-Fehler. Root Cause (tiefer im Log):

```
creating device cilium_geneve: invalid argument
```

Der Kernel der Docker-Desktop-VM kann kein GENEVE-Device anlegen (kein arm64-Problem —
VXLAN läuft auf derselben Maschine). Drei Cilium-Versionen probiert, dreimal derselbe Fehler
→ Umgebungsproblem, kein Versions-Bump hilft.
Vollständige Analyse: [Troubleshooting-Playbook, Fall 1 + 2](../cheatsheets/troubleshooting-playbook.md)

**Fix — VXLAN statt GENEVE** (Konzept identisch):

```bash
helm upgrade cilium cilium/cilium --version 1.19.4 --namespace kube-system \
  --set routingMode=tunnel --set tunnelProtocol=vxlan --set ipam.mode=cluster-pool
kubectl -n kube-system rollout restart ds/cilium   # ConfigMap-Änderung ≠ aktiv! (Fall 2)
cilium status --wait
```

---

## Aufgabe 4 — Tunnel-Modus verifizieren

**1. Config:**

```bash
cilium config view | grep -E "routing|tunnel"
# routing-mode      tunnel
# tunnel-protocol   vxlan
```

**2. Routing-Tabelle — der Kernbeweis:**

```
10.0.0.0/24 via 10.0.1.39 dev cilium_host    ← Remote-Pod-CIDR!
10.0.2.0/24 via 10.0.1.39 dev cilium_host    ← Remote-Pod-CIDR!
```

`10.0.1.39` ist die **eigene** cilium_host-IP des Workers (die CiliumInternalIP aus der
CiliumNode CR, als /32). Das sind **Trichter-Routen**: "gib's an mich selbst, auf dem
Cilium-Device" — der Kernel weiß NICHT, wo die Pods wohnen. Vergleich:

| Modus | via zeigt auf | Device | Wer kennt den Ziel-Node? |
|-------|---------------|--------|--------------------------|
| Native | fremde Node-IP | `eth0` | der **Kernel** |
| Tunnel | eigene cilium_host-IP | `cilium_host` | die **eBPF ipcache-Map** |

**3. Devices:**

```
12: cilium_net@cilium_host   ← veth-Pair (beide Modi)
13: cilium_host@cilium_net   ← veth-Pair (beide Modi)
40: cilium_vxlan             ← NEU: Tunnel-Device, kein @ = kein veth!
```

---

## Aufgabe 5 — ipcache lesen

```bash
kubectl -n kube-system exec ds/cilium -- cilium-dbg bpf ipcache list
```

```
10.0.1.113/32   identity=50219  tunnelendpoint=172.18.0.3  flags=hastunnel   ← remote Pod
10.0.2.0/24     identity=2      tunnelendpoint=172.18.0.2  flags=hastunnel   ← remote CIDR
10.0.0.177/32   identity=4      tunnelendpoint=0.0.0.0     flags=<none>      ← LOKAL
0.0.0.0/0       identity=2      tunnelendpoint=0.0.0.0                       ← world catch-all
```

1. **Key = Pod-IP, Value = Node-IP (`tunnelendpoint`) + Identity** — Routing UND Security
   in einem Map-Lookup. (Die Ziel-IP ist die Frage, nicht Teil der Antwort!)
2. `hastunnel` = verpacken und an diese Node-eth0-IP schicken. `0.0.0.0` = kein Tunnel
   nötig (lokal oder direkt erreichbar).
3. **Ein Node tunnelt nie zu sich selbst** — die Einträge ohne tunnelendpoint verraten den
   lokalen Pod-CIDR. Hier: `10.0.0.x` lokal → Agent läuft auf der Control Plane (172.18.0.4).

Well-Known-Identities: `1` = host, `2` = world, `4` = health, `6` = remote-node.
Große Nummern = dynamische Workload-Identities.

---

## Das Bild — VXLAN-Tunnel-Modus (Pod A → Pod B)

```
 NODE: cilium-lab-worker (172.18.0.3)                NODE: cilium-lab-worker2 (172.18.0.2)
┌─────────────────────────────────────┐             ┌─────────────────────────────────────┐
│  ┌───────┐                          │             │                          ┌───────┐  │
│  │ Pod A │ 10.0.1.113               │             │               10.0.2.208 │ Pod B │  │
│  └───┬───┘                          │             │                          └───▲───┘  │
│      │ veth (lxc…)                  │             │                              │      │
│      ▼                              │             │                              │      │
│  ╔═══════════════════════════╗      │             │      ╔═══════════════════╗   │      │
│  ║ eBPF am tc-Hook           ║      │             │      ║ eBPF: auspacken,  ║───┘      │
│  ║                           ║      │             │      ║ Identity prüfen   ║          │
│  ║ Kernel-Route sagt nur:    ║      │             │      ║ (Policy!)         ║          │
│  ║ "10.0.2.0/24 via MICH     ║      │             │      ╚═════════▲═════════╝          │
│  ║  selbst (Trichter!)"      ║      │             │                │                    │
│  ║                           ║      │             │          cilium_vxlan               │
│  ║ ipcache-Lookup:           ║      │             │                ▲                    │
│  ║  10.0.2.208 → ID=4,       ║      │             │                │                    │
│  ║  tunnelendpoint=172.18.0.2║      │             │                │                    │
│  ╚═══════════╦═══════════════╝      │             │                │                    │
│              ▼                      │             │                │                    │
│        cilium_vxlan                 │             │                │                    │
│      ┌──── VERPACKEN ─────┐         │             │                │                    │
│      ▼                    │         │             │                │                    │
│    eth0 ────────────────────────────┼─────────────┼──► eth0 ───────┘                    │
└─────────────────────────────────────┘   UNDERLAY  └─────────────────────────────────────┘
                                       sieht NUR das:

              ┌──────────────────────────────────────────────────────┐
              │  OUTER: src 172.18.0.3 → dst 172.18.0.2  (Node-IPs!) │
              │  ├ VXLAN-Header (+ Identity von Pod A)               │
              │  └ INNER: src 10.0.1.113 → dst 10.0.2.208 (Pod-IPs)  │
              └──────────────────────────────────────────────────────┘
```

**Drei Merk-Anker:**
1. **Trichter** — Kernel-Tabelle kippt alles nur in den Cilium-Trichter
2. **Adressbuch** — ipcache liefert "wo wohnst du" + "wer bist du"
3. **Briefumschlag** — cilium_vxlan verpackt mit Node-Adressen; das Underlay kennt keine
   Pod-IPs → kein BGP, keine statischen Routen nötig

Native Mode = **kein Umschlag**: Pod-IPs fahren nackt durchs Underlay — deshalb muss dort
jeder die Pod-CIDRs kennen.

---

## RZ-Profi-Tipps des Tages

- **via-Ziel + Device lesen, nicht Routen zählen:** `via <fremde Node-IP> dev eth0` = Native;
  `via <eigene IP> dev cilium_host` = Tunnel. Routing-Modus in 10 Sekunden erkannt, ohne Config.
- **tcpdump im Tunnel-Modus:** Auf `eth0` nur Node-zu-Node UDP 8472 sichtbar
  (`tcpdump -i eth0 udp port 8472`); ausgepackte Pod-Pakete auf `cilium_vxlan` lauschen.
- **Retry-Loop im festen Takt = Umgebungsproblem** — Kernel/Module prüfen, nicht Versionen würfeln.
- **Nach jeder Cilium-Config-Änderung:** Pod-Age gegen Änderungszeitpunkt prüfen
  (`helm upgrade` rollt die Agents nicht neu!).
