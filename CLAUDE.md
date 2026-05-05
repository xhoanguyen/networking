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
- Vom User bestätigen lassen

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

**Modul:** 03 — Linux Networking Advanced
**Tag:** 22 — Review: Bridge Deep Dive (next)
**VM:** `multipass shell rz-node` — Interface heißt `enp0s1` (nicht `eth0`)

---

## Abgeschlossene Tage

→ siehe [`modules/progress.md`](modules/progress.md)

---

## Modul 03 — Linux Networking Advanced

Themenpool (Stack-Kontext: RKE2, Cilium, MetalLB, HAProxy, Istio, OPA Gatekeeper, Ceph — kein IPv6):
VLANs, Bonding/LACP, tcpdump, eBPF, VXLAN, Cilium, MetalLB, Istio, Kubernetes Netzwerk-Debugging

Geplante Tage:
- Tag 21 ✅ — Review: Netzwerk-Debugging Systematisch
- Tag 22 — Review: Bridge Deep Dive
- Tag 23 — tcpdump
- Tag 24 — conntrack & iptables Vertiefung
- Tag 25 — STP + Subnetz-Masken
- Tag 26 — Subnetz-Theorie
- Tag 27 — VLANs
- Tag 28 ✅ — eBPF Fundamentals (Architecture, Maps, Programs)
- Tag 29 — eBPF Networking (XDP, tc hooks, Cilium)
- Tag 30 — eBPF Praxis (BCC Tools, bpftool, live Traffic)

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
| `modules/02-linux-networking/days/day-18.md` | Tag 18 Übungen |
| `modules/02-linux-networking/days/day-18_SOLUTION.md` | Tag 18 Lösung |
| `modules/02-linux-networking/days/day-19.md` | Tag 19 Übungen |
| `modules/02-linux-networking/days/day-19_SOLUTION.md` | Tag 19 Lösung |
| `modules/02-linux-networking/days/day-20.md` | Tag 20 Final Exam |
| `modules/02-linux-networking/days/day-20_SOLUTION.md` | Tag 20 Lösung |
| `modules/02-linux-networking/days/FAQ_day_13.md` | FAQ Tag 13 |
| `modules/02-linux-networking/cheatsheets/rz_profi_tipps.md` | RZ Profi-Tipps Sammlung |
| `modules/03-linux-networking-advanced/days/day-21_setup.sh` | Tag 21 Broken Setup Script |
| `modules/progress.md` | Alle abgeschlossenen Tage mit Learnings |
