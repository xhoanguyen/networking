# RZ-Relevanz — Modul 02: Linux Networking

Sammlung aller RZ-relevanten Verbindungen aus Modul 02.
Wird laufend ergänzt.

---

## Tag 11 — ip-Commands

### `ip addr` / `ip link`
Tägliches Handwerkszeug auf jedem RKE2-Node:
- Welche IPs hat der Node?
- Welche Interfaces sind aktiv?

### `ip route`
- Wie wird Traffic auf dem Node geroutet?
- Relevant beim Debuggen von Pod-zu-Pod Traffic über verschiedene Nodes

### `ip neigh` — ARP-Tabelle
Bei MetalLB im L2-Mode ist die ARP-Tabelle entscheidend. Wenn ein LoadBalancer-Service keine Verbindung bekommt:
- Hat der Node überhaupt eine ARP-Antwort für die LoadBalancer-IP bekommen?
- `ip neigh show` ist einer der ersten Checks

### MTU
Cilium und andere CNIs fügen Header zu Paketen hinzu (z.B. VXLAN-Tunnel). Wenn die MTU nicht angepasst wird:
- Pakete werden zu groß
- Pakete werden fragmentiert oder gedroppt
- Symptom: sporadische Verbindungsabbrüche, schwer zu debuggen

### NAT / PAT
Pods haben IPs aus dem PodCIDR (z.B. `10.244.x.x`) — außerhalb des Clusters unbekannt. Der Node macht NAT:
- Pod-IP wird gegen Node-IP getauscht
- Cilium ersetzt klassisches iptables-NAT mit eBPF (Modul 08)

### Bridge / veth pairs
Multipass nutzt `bridge100` — dasselbe Konzept steckt in K8s:
- Jeder Pod ist über ein veth pair mit einer Linux Bridge auf dem Node verbunden
- CNI (Cilium) konfiguriert diese Verbindungen automatisch

### Routing-Tabellen (aus LARTC)
Linux verwaltet intern drei Routing-Tabellen: `local`, `main`, `default`. `ip route show` zeigt nur `main`. Im RZ relevant bei Policy Routing — z.B. wenn Traffic von verschiedenen Interfaces unterschiedlich geroutet werden soll (Modul 04).

### ARP-Einträge verfallen nach ~15 Minuten
Bei MetalLB L2-Mode: wenn ein Node ausfällt und ein anderer die LoadBalancer-IP übernimmt, müssen alle Geräte im Netz ihren ARP-Cache aktualisieren. Bis das passiert (~15 Min oder bei Gratuitous ARP sofort) kann Traffic verloren gehen.
