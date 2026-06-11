# Abgeschlossene Tage

### Tag 11 ✅ — Erste Schritte mit Multipass
- Multipass installiert, VM `rz-node` aufgesetzt (2 CPU, 2G RAM, 10G Disk)
- Erste `ip`-Commands: `ip link`, `ip addr`, `ip route`, `ip neigh`, `ss -tuln`
- Interface heißt `enp0s1` (nicht `eth0`)
- Unterschied `lo` vs. physisches Interface verstanden
- `ping` und `traceroute` als erste Connectivity-Tests

### Tag 12 ✅ — Linux Routing & ARP vertiefen
- Linux hat drei Routing-Tabellen: `local`, `main`, `default`
- `ip route show` zeigt nur `main` — `ip route show table all` zeigt alles
- Longest Prefix Match: `/32` schlägt `/24` schlägt `/0`
- ARP-Zustandsmaschine: `REACHABLE` → `STALE` → `DELAY` → `PROBE` → `FAILED`
- Gratuitous ARP: proaktive Cache-Aktualisierung bei Failover (relevant für MetalLB L2-Mode)
- MTU-Debugging: `ping -M do -s 1472` — kleiner Ping geht, große Transfers hängen = MTU-Problem

### Tag 13 ✅ — Der `ip`-Befehl: Komplett-Training
- **Block A** — `ip link`: Interfaces lesen, Statistiken (-s -h), MAC, promisc, up/down
- **Block B** — `ip addr`: IPs anzeigen, hinzufügen/entfernen, JSON + jq, `ip addr get`
- **Block C** — `ip route`: Default Route, `ip route get`, statische Route, local-Tabelle, Policy-Routing
- **Block D** — ARP / Neighbor-Cache (`ip neigh`)

### Tag 14 ✅ — Network Namespaces (`ip netns`)
- Isolation durch fehlende Konnektivität (nicht Firewall)
- `ip netns add/exec/delete`, `nsenter -t <pid> -n`
- Kernel injiziert Routen automatisch bei `ip link set lo up`

### Tag 15 ✅ — veth pairs
- veth pair erstellen, Enden in Namespaces verschieben
- IPs vergeben, Interfaces hochbringen, Ping zwischen Namespaces
- Connected Route wird automatisch vom Kernel angelegt
- NO-CARRIER wenn Gegenstück DOWN ist

### Tag 16 ✅ — Linux Bridge
- Bridge = virtueller L2-Switch im Kernel (`ip link add name br0 type bridge`)
- Bridge-Enden der veth pairs via `master`-Keyword als Ports enslaven
- `bridge link show` zeigt Ports und deren State (`forwarding`, `disabled`)
- `bridge fdb show` zeigt die MAC-Adress-Tabelle (Forwarding Database)
- Bridge lernt MACs dynamisch — dynamische Einträge verschwinden nach Timeout (~300s)
- Unknown Unicast Flooding: unbekannte MACs werden an alle Ports geflutet
- Ping zwischen Namespaces läuft auf L2 — kein Routing nötig solange gleicher Subnet
- `man ip-link` und `man bridge` sind die Primärquellen

### Tag 17 ✅ — iptables / Netfilter
- Netfilter = Kernel-Framework; `iptables` = Werkzeug zum Konfigurieren
- 4 Tabellen: `filter` (Firewall), `nat` (Adressübersetzung), `mangle` (Header-Manipulation), `raw` (Conntrack-Bypass)
- Chains: `INPUT`, `OUTPUT`, `FORWARD`, `PREROUTING`, `POSTROUTING` — Paket durchläuft fest definierte Reihenfolge
- `filter` ist die Standard-Tabelle — keine `-t` Angabe = `filter`
- Erste Regel die matched gewinnt — Reihenfolge matters
- Policy am Ende der Chain: `ACCEPT` (default) oder `DROP` (produktiv)
- `DROP` = Paket schweigend verwerfen; `REJECT` = Absender bekommt ICMP-Fehler zurück
- `conntrack` trackt Verbindungszustände: `NEW`, `ESTABLISHED`, `RELATED`, `INVALID`
- FORWARD Chain ist relevant für Namespace-Traffic der den Host als Router nutzt
- Debugging: `iptables -L -v -n --line-numbers`, `conntrack -L`, `iptables -t nat -L -v -n`

### Tag 18 ✅ — NAT
- IP Forwarding (`net.ipv4.ip_forward`) muss aktiv sein — sonst wirft der Kernel fremde Pakete still weg
- `sysctl -w net.ipv4.ip_forward=1` — temporär aktivieren, sehr wahrscheinlich mit `sudo`
- MASQUERADE in `nat` Tabelle, `POSTROUTING` Chain — ersetzt Absender-IP dynamisch mit Host-IP
- DNAT in `nat` Tabelle, `PREROUTING` Chain — ersetzt Ziel-IP (Port Forwarding)
- conntrack macht NAT stateful — Antwortpakete werden automatisch zurückübersetzt
- DNAT für lokalen Traffic (vom Host selbst) braucht zusätzlich eine Regel in `OUTPUT` Chain
- Default Route in Namespaces nicht vergessen — ohne sie kommen Pakete nicht raus
- Kubernetes NodePort = DNAT: externer Port → Pod-IP:Port

### Tag 19 ✅ — Container-Netzwerk von Null
- Bestandsaufnahme zuerst — prüfen was noch steht bevor man baut
- Vollständige Reihenfolge: Namespace → Bridge → veth pairs → IPs → Default Routes → IP Forwarding → MASQUERADE
- L2-Konnektivität zwischen Namespaces läuft über Bridge — kein Routing, kein Host-IP-Stack
- conntrack live beobachtet: `src=10.0.0.2 dst=8.8.8.8` Hinweg, `src=8.8.8.8 dst=192.168.2.2` Rückweg
- DNAT für Port Forwarding: `PREROUTING` für externen Traffic, zusätzlich `OUTPUT` für lokalen Traffic
- Das ist exakt der Mechanismus den Kubernetes/CRI-O für jeden Pod verwendet

### Tag 20 ✅ — Final Exam: Linux Networking
- 14/18 Theoriefragen richtig — Kernkonzepte sitzen
- Lücken: conntrack vs. iptables-Counter (Fragen 9/10), NO-CARRIER Ursache (13), /32 Subnetz-Verhalten (14)
- Lab komplett aufgebaut und aufgeräumt (ns-web, ns-db, ns-cache + Bridge + NAT)
- Vertiefungsthemen für Modul 03: conntrack (Tag 24), STP + Subnetz-Masken (Tag 25), Subnetz-Theorie (Tag 26)

### Tag 23 ✅ — tcpdump (Paket-Analyse im RZ)
- tcpdump arbeitet auf L2 — sieht rohe Ethernet-Frames, setzt Interface in promiscuous mode
- BPF (Berkeley Packet Filter) ist das Filter-System — läuft direkt im Kernel, Vorgänger von eBPF
- `-nn` verhindert DNS-Lookups während des Captures — kein eigener Traffic, kein Rauschen
- `-i br0` vs. `-i any` — gezielt vs. breiter Überblick; im RZ erst `any`, dann gezielt
- BPF-Filter: `host X and host Y`, `port 80`, `arp`, `icmp`, `not port 22`
- `-w /tmp/capture_$(date +%Y%m%d_%H%M).pcap` — einmal capturen, beliebig oft auslesen
- `packets dropped by kernel` in der Zusammenfassung = Buffer überlastet, Filter zu weit
- `-A` zeigt Payload als ASCII — HTTP-Traffic ist im Klartext lesbar (Sicherheitsproblem)
- `-e` zeigt Ethernet-Header mit MAC-Adressen — direkte Verbindung zur Bridge-FDB
- Istio mTLS schützt internen Kubernetes-Traffic vor genau diesem Angriff

---

> **Modul 03 pausiert** — offene Tage (22, 24–27, 29–30) als optional markiert. Weiter mit Modul 04 (Cilium CCA).

### Tag 34 ✅ — Ch5: Routing (Native Routing, Tunnel-Modus, ipcache)
- Merksatz: Native legt die Routing-Intelligenz in die Kernel-Tabelle, Tunneling in die eBPF-Maps (ipcache)
- Native: via-Routen zu **fremden Node-IPs** über eth0 — eine Route pro Remote-CIDR-Block, nicht pro Pod
- Tunnel: nur **Trichter-Routen** auf die eigene cilium_host-IP — ipcache-Lookup liefert tunnelendpoint + identity
- `cilium_vxlan` = eigenständiges Tunnel-Device (kein `@` in `ip link` = kein veth)
- Outer-Paket trägt Node-IPs, Inner-Paket Pod-IPs → Underlay braucht keine Pod-CIDR-Routen
- Ein Node tunnelt nie zu sich selbst — ipcache-Einträge ohne tunnelendpoint = lokaler Pod-CIDR
- Troubleshooting-Fall: GENEVE-Device-Erstellung scheitert am Docker-Desktop-Kernel (`invalid argument`) — Compile-Fehler waren nur Folgesymptom; 3 Versionen probiert = Umgebungsproblem bewiesen → VXLAN-Fallback
- `helm upgrade` ändert nur die ConfigMap — Agent liest Config nur beim Start → `rollout restart` nötig
- Neu: [Troubleshooting-Playbook](04-cilium/cheatsheets/troubleshooting-playbook.md) für die RZ-Praxis angelegt

### Tag 33 ✅ — Ch4: IPAM Part 2 (Multi-Pool, ENI, Dual-Stack)
- Multi-Pool IPAM: mehrere `CiliumPodIPPool` CRDs, Zuweisung via `ipam.cilium.io/ip-pool` Annotation auf Namespace
- `maskSize` bestimmt die Block-Granularität pro Node — Nodes bekommen dynamisch weitere Blöcke wenn der aktuelle voll ist
- Nodes können gleichzeitig Blöcke aus mehreren Pools halten (default + tenant-pool)
- AWS ENI IPAM: Cilium delegiert IP-Verwaltung an EC2 API — nur für AWS, CCA-relevant
- Dual-Stack: `ipFamily: dual` in Kind + `ipv6.enabled: true` — Kubernetes muss dual-stack enabled sein (CCA-relevant)
- `kubectl wait --for=condition=Ready` ist der richtige Weg statt `sleep` — funktioniert für Nodes, Pods, beliebige Conditions

### Tag 32 ✅ — Ch4: IPAM Part 1 (kubernetes vs. cluster-scope)
- `cluster-pool` ist der interne Helm-Wert für cluster-scope (Default-Modus)
- kubernetes-mode: kube-controller-manager teilt CIDRs zu, Cilium liest `.spec.podCIDR` vom Node
- cluster-pool mode: Cilium Operator teilt CIDRs aus eigenem Pool zu — `.spec.podCIDR` auf dem Node gilt nicht
- `cilium config view | grep ipam` — schnellster Check für den aktiven Modus
- `kubectl get ciliumnodes -o jsonpath=...` ist die richtige Quelle für Pod-CIDRs in cluster-pool mode
- Beweis: Pod-IPs kommen aus dem Cilium-CIDR (`10.0.x.0/24`), nicht aus dem Kubernetes-CIDR (`10.244.x.0/24`)
- IPAM-Mode wechseln ist destruktiv — Day-0-Entscheidung

---

### Tag 21 ✅ — Review: Netzwerk-Debugging Systematisch
- OSI Bottom-Up Debugging: `ip link` → `ip addr` → `ip route` → Host-Konfiguration
- `LOWERLAYERDOWN` = Peer des veth-Paares ist DOWN
- `NO-CARRIER` auf Bridge = keine aktiven Ports angehängt
- `link-netns` zeigt wo der **Peer** steckt, nicht das Interface selbst
- Connected Route erscheint automatisch wenn Interface UP ist und eine IP hat — nicht durch Traffic
- Drei Fehler im Broken Lab gefunden und gefixt: veth-web DOWN, veth-cache-br nicht an br0, ip_forward=0
- Im RZ: immer Schicht für Schicht debuggen — nie raten, immer messen
