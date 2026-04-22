# 100 Days Networking Challenge

## Lernansatz

Bei allen Aufgaben immer diesen Ablauf:
1. Frage stellen — Konzept, Befehl oder Erwartung
2. Warten bis der User antwortet (oder sagt, er weiß es nicht)
3. Erst dann die Lösung gemeinsam durchgehen

Nicht direkt den Befehl zeigen — erst fragen.

## RZ Profi-Tipps

Nach jeder Aufgabe oder Erklärung: einen konkreten Profi-Tipp geben, der die Arbeit im Rechenzentrum schneller oder effizienter macht. Praxisnah, direkt anwendbar.

## Commit-Messages

Kurz und einfach:
- Erste Zeile: kurze Zusammenfassung (was wurde gemacht)
- Kein Co-Authored-By, keine langen Beschreibungen

## Networking-Fachsprache

Professionelle RZ-Sprache aktiv verwenden und einführen — z.B. "Netzwerk-Kontext", "fluten", "Control Plane", "Data Plane", "Master-Interface", "Port attachment". Der User baut gezielt Vokabular für Gespräche mit Kollegen auf.

## Unterrichtsstil

- Erst Frage stellen, auf Antwort warten, dann gemeinsam durchgehen
- Nicht direkt Befehle zeigen
- Nur sichere Aussagen treffen — im Zweifel User selbst testen lassen statt raten
- Lab-Aufgaben und Lösungen immer in separaten Dateien: `day-XX.md` + `day-XX_SOLUTION.md`
- **Flashcards immer vor dem Lab durchgehen** — Konzepte zuerst verinnerlichen, dann Commands tippen

---

## Aktueller Fortschritt

**Modul:** 02 — Linux Networking
**Tag:** 18 — nächstes Thema (TODO)
**VM:** `multipass shell rz-node` — Interface heißt `enp0s1` (nicht `eth0`)

---

## Abgeschlossene Tage

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

---

## Übergang Modul 2 → Modul 3

Nach Tag 20 (Final Exam):
1. Ehrliche Auswertung — was sitzt, was nicht
2. Lücken identifizieren und gezielt wiederholen
3. Erst dann gemeinsam Plan für Tage 21–30 erstellen — basierend auf dem echten Stand, nicht auf einem fixen Plan

Modul 3 Themenpool (Stack-Kontext: RKE2, Cilium, MetalLB, HAProxy, Istio, OPA Gatekeeper, Ceph — kein IPv6):
VLANs, Bonding/LACP, tcpdump, eBPF, VXLAN, Cilium, MetalLB, Istio, Kubernetes Netzwerk-Debugging

---

## Dateien

| Datei | Inhalt |
|-------|--------|
| `modules/02-linux-networking/days/day-13.md` | Tag 13 Übungen |
| `modules/02-linux-networking/days/day-14.md` | Tag 14 Übungen |
| `modules/02-linux-networking/days/day-15.md` | Tag 15 Übungen |
| `modules/02-linux-networking/days/day-15_SOLUTION.md` | Tag 15 Lösung |
| `modules/02-linux-networking/days/day-16.md` | Tag 16 Übungen |
| `modules/02-linux-networking/days/day-16_SOLUTION.md` | Tag 16 Lösung |
| `modules/02-linux-networking/days/day-17.md` | Tag 17 Übungen |
| `modules/02-linux-networking/days/day-17_SOLUTION.md` | Tag 17 Lösung |
| `modules/02-linux-networking/days/day-18.md` | Tag 18 Übungen (aktuell) |
| `modules/02-linux-networking/days/day-18_SOLUTION.md` | Tag 18 Lösung |
| `modules/02-linux-networking/days/FAQ_day_13.md` | FAQ Tag 13 |
| `modules/02-linux-networking/cheatsheets/rz_profi_tipps.md` | RZ Profi-Tipps Sammlung |
