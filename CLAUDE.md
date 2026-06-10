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
- **Immer auf Englisch**
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

**Modul:** 04 — Cilium: Up and Running (CCA Vorbereitung)
**Tag:** 34 — Ch5: Routing (Native Routing, GENEVE, Node-Routes) (nächstes)
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
- Tag 22 — Review: Bridge Deep Dive *(offen, optional)*
- Tag 23 ✅ — tcpdump
- Tag 24 — conntrack & iptables Vertiefung *(optional)*
- Tag 25 — STP + Subnetz-Masken *(optional)*
- Tag 26 — Subnetz-Theorie *(optional)*
- Tag 27 — VLANs *(optional)*
- Tag 28 ✅ — eBPF Fundamentals (Architecture, Maps, Programs)
- Tag 29 — eBPF Networking (XDP, tc hooks, Cilium) *(optional)*
- Tag 30 — eBPF Praxis (BCC Tools, bpftool, live Traffic) *(optional)*

## Modul 04 — Cilium: Up and Running (CCA Vorbereitung)

Buch: *Cilium: Up and Running* von Nico Vibert, Filip Nikolic, James Laverack
Repo: `/Users/xhoa/workspace/cilium-up-and-running/`

**CCA Exam-Domains (Gewichtung):** Architecture 20% · Network Policy 18% · Service Mesh 16% · Observability 10% · Installation 10% · Cluster Mesh 10% · eBPF 10% · BGP & External Networking 6%

**Regeln für dieses Modul:**
- Nach jedem Tag: **RZ-Transfer-Block** in `CCA-exam.md` — "Wie ist das bei uns auf RKE2 konfiguriert?" (Antworten vom Platform-Team / `cilium config view` einarbeiten sobald verfügbar)
- Flashcards: vorhandene Karten in `flashcards/` **täglich vor dem Lab durchgehen**; neue Karten aus `CCA-exam.md` nur **alle 3 Tage** generieren (bzw. an Mini-Review-Tagen)
- Exam-Ballast (AWS ENI, Azure IPAM, Dual-Stack) nur einmal verstehen, nicht vertiefen — Stack ist on-prem RKE2 ohne IPv6

Geplante Tage:
- Tag 31 ✅ — Ch3: Cilium Basics (Installation, kind, erste Network Policy)
- Tag 32 ✅ — Ch4: IPAM Part 1 (kubernetes/cluster-scope Modi)
- Tag 33 ✅ — Ch4: IPAM Part 2 (ENI, multi-pool, dual-stack)
- Tag 34 — Ch5: Routing (Native Routing, GENEVE, Node-Routes)
- Tag 35 — Ch6: kube-proxy Replacement Part 1
- Tag 36 — Ch6: kube-proxy Replacement Part 2
- Tag 37 — Ch6: kube-proxy Replacement Part 3 + Lab
- Tag 38 — Mini-Review Ch3–Ch6 + Flashcards anlegen (Quiz: 10 Fragen)
- Tag 39 — Ch7: Ingress & Gateway API + Service-Mesh-Konzepte (sidecar vs. sidecar-less, mutual auth, warum Gateway API > Ingress) *(Exam: 16%-Domain)*
- Tag 40 — Ch8: Load Balancing (DSR, Maglev, LRP)
- Tag 41 — Ch9: Cluster Mesh Part 1
- Tag 42 — Ch9: Cluster Mesh Part 2
- Tag 43 — Ch9: Cluster Mesh Part 3 + Lab
- Tag 44 — Ch10: L2 Announcements + LB-IPAM + **BGP-Konzepte** *(eigene Exam-Domain)*
- Tag 45 — Lab: MetalLB L2-Mode vs. Cilium LB-IPAM/L2 Announcements *(Job-Transfer: MetalLB-Ablösung)*
- Tag 46 — Ch11: Egress Gateway & Bandwidth Manager
- Tag 47 — Ch12: Network Policies Part 1
- Tag 48 — Ch12: Network Policies Part 2
- Tag 49 — Ch12: Network Policies Part 3 + Troubleshooting
- Tag 50 — Istio + Cilium: wer macht was? (mTLS-Schichten, L7-Policy-Zuständigkeit, Sidecar vs. CNI) *(Job-Transfer)*
- Tag 51 — Ch13: DNS & FQDN Policies
- Tag 52 — Mini-Review Ch7–Ch13 + Flashcards ergänzen (Quiz: 10 Fragen)
- Tag 53 — Ch14: Encryption (WireGuard/IPSec, East-West vs. North-South)
- Tag 54 — Ch15: Hubble Part 1 (CLI, L7-Visibility)
- Tag 55 — Ch15: Hubble Part 2 + Lab: Policy-Drop systematisch debuggen *(häufigster RZ-Praxisfall)*
- Tag 56 — Ch16: Metrics (Prometheus & Grafana)
- Tag 57 — Cilium auf RKE2 (Multipass-VM, HelmChartConfig, kube-proxy-frei) *(Job-Transfer: Brücke kind → RKE2)*
- Tag 58 — Gesamtreview Part 1 (Ch3–Ch9)
- Tag 59 — Gesamtreview Part 2 (Ch10–Ch16)
- Tag 60 — Mock Exam 1 + Lücken identifizieren
- Tag 61 — Lücken aufarbeiten (schwächste Domains aus Mock 1)
- Tag 62 — Mock Exam 2: finale CCA Prüfungssimulation

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
| `modules/03-linux-networking-advanced/days/day-28.md` | Tag 28 Übungen |
| `modules/03-linux-networking-advanced/days/day-23.md` | Tag 23 Übungen |
| `modules/03-linux-networking-advanced/days/day-23_SOLUTION.md` | Tag 23 Lösung |
| `modules/03-linux-networking-advanced/days/day-28_SOLUTION.md` | Tag 28 Lösung |
| `modules/04-cilium/CCA-exam.md` | CCA Exam Notizen (wird täglich ergänzt) |
| `modules/04-cilium/flashcards/ch3-cilium-basics.md` | Flashcards Ch3 (Tag 31) |
| `modules/04-cilium/flashcards/ch4-ipam.md` | Flashcards Ch4 (Tag 32–33) |
| `modules/04-cilium/days/day-31.md` | Tag 31 Übungen |
| `modules/04-cilium/days/day-31_SOLUTION.md` | Tag 31 Lösung |
| `modules/04-cilium/days/day-32.md` | Tag 32 Übungen |
| `modules/04-cilium/days/day-32_SOLUTION.md` | Tag 32 Lösung |
| `modules/04-cilium/days/day-33.md` | Tag 33 Übungen |
| `modules/04-cilium/days/day-33_SOLUTION.md` | Tag 33 Lösung |
| `modules/progress.md` | Alle abgeschlossenen Tage mit Learnings |
