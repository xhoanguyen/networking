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
**Tag:** 16 — Linux Bridge (IN PROGRESS)
**VM:** `multipass shell rz-node` — Interface heißt `enp0s1` (nicht `eth0`)

---

## Abgeschlossene Tage

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

---

## Tag 16 — Linux Bridge (HIER WEITERMACHEN)

**Ziel:** Drei Namespaces über eine Linux Bridge verbinden (L2-Switch-Prinzip)

**Konzept:**
- Bridge = virtueller L2-Switch im Kernel
- Bridge braucht eine IP um selbst als Gateway zu fungieren
- veth pairs verbinden Namespaces mit der Bridge
- Bridge-Seite des veth = Port der Bridge (`master`-Keyword)
- `man ip-link` ist die Primärquelle für Bridge-Befehle

**VM-Stand (wo wir aufgehört haben):**

```
# Bridge
br0: UP, IP 10.0.0.1/24

# Namespaces
ns1, ns2, ns3: erstellt

# veth pairs (erstellt, aber noch nicht vollständig konfiguriert)
veth-ns1  <-->  veth-ns1-br
veth-ns2  <-->  veth-ns2-br
veth-ns3  <-->  veth-ns3-br
```

**Nächster Schritt:**

Bridge-Enden der veth pairs als Ports an `br0` hängen:

```bash
ip link set veth-ns1-br master br0
ip link set veth-ns2-br master br0
ip link set veth-ns3-br master br0
```

Danach:
1. Bridge-Enden UP bringen (`veth-ns1-br`, `veth-ns2-br`, `veth-ns3-br`)
2. Namespace-Enden in die Namespaces verschieben (`ip link set veth-ns1 netns ns1`, usw.)
3. IPs in den Namespaces vergeben (z.B. `10.0.0.11/24` in ns1, `10.0.0.12/24` in ns2, `10.0.0.13/24` in ns3)
4. Namespace-Interfaces UP bringen
5. Ping zwischen ns1 und ns2 testen

**Lernziel:** Verstehen warum der Ping funktioniert — welche Schicht entscheidet (L2 vs L3)?

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
