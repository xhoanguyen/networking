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

---

## Aktueller Fortschritt

**Modul:** 02 — Linux Networking
**Tag:** 17 — nächstes Thema (TODO)
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

---

## Modul 3 — Plan (Dateien werden bei Bedarf erstellt)

Stack-Kontext: RKE2, Cilium (CNI), MetalLB, HAProxy, Istio, OPA Gatekeeper, Ceph — kein IPv6

| Tag | Thema |
|-----|-------|
| 21 | VLANs (802.1Q) — Node-Netzwerke im RZ |
| 22 | Bonding / LACP — HA NICs |
| 23 | tcpdump tief — Paketanalyse im RZ |
| 24 | eBPF Grundlagen — Fundament für Cilium |
| 25 | VXLAN / Overlay-Netzwerke |
| 26 | Cilium Architektur — wie euer CNI wirklich funktioniert |
| 27 | MetalLB + HAProxy — L4 Load Balancing im Stack |
| 28 | Istio Grundlagen — Service Mesh, mTLS, Sidecar |
| 29 | Kubernetes Netzwerk-Debugging — kubectl, Hubble, tcpdump im Cluster |
| 30 | Final Exam Modul 3 |

---

## Dateien

| Datei | Inhalt |
|-------|--------|
| `modules/02-linux-networking/days/day-13.md` | Tag 13 Übungen |
| `modules/02-linux-networking/days/day-14.md` | Tag 14 Übungen |
| `modules/02-linux-networking/days/day-15.md` | Tag 15 Übungen |
| `modules/02-linux-networking/days/day-15_SOLUTION.md` | Tag 15 Lösung |
| `modules/02-linux-networking/days/day-16.md` | Tag 16 Übungen (aktuell) |
| `modules/02-linux-networking/days/day-16_SOLUTION.md` | Tag 16 Lösung |
| `modules/02-linux-networking/days/FAQ_day_13.md` | FAQ Tag 13 |
| `modules/02-linux-networking/cheatsheets/rz_profi_tipps.md` | RZ Profi-Tipps Sammlung |
