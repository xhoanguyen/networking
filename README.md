# 100-Days Networking Challenge

Preparing for a RZ team transition. From zero to solid networking skills in 100 days.

## Sources

- **Current (Module 04):** Vibert, Nikolic & Laverack — *Cilium: Up and Running* (CCA Vorbereitung)
- **Primary:** Harald Zisler — *Computer-Netzwerke* (8th edition, 456 pages)
- **Deep Dive:** Peter Dordal — *Rechnernetze – Das umfassende Lehrbuch* (1st edition, 2023)
- **Systems Perspective:** Peterson & Davie — *Computer Networks: A Systems Approach*
- **Reference:** Tanenbaum & Wetherall — *Computer Networks* (5th edition)
- **Linux Networking:** LARTC — *Linux Advanced Routing & Traffic Control*

## Daily Routine

| Phase | What | Duration |
|-------|------|----------|
| Theorie | Flashcard-Review + Reading | ~25-30 min |
| Praxis | Lab-Aufgaben (day-XX.md → day-XX_SOLUTION.md) | ~45-60 min |

Reihenfolge ist fix: erst Flashcards, dann Lab.

## Modules & Progress

> Ausgerichtet auf den RZ-Stack: RKE2, Cilium, MetalLB, HAProxy, Istio, VictoriaMetrics

| # | Module | Days | Status |
|---|--------|------|--------|
| 01 | [Grundlagen (OSI, TCP/IP, DNS)](modules/01-grundlagen/) | 1-10 | [x] Done |
| 02 | [Linux Networking (ip, netns, veth, bridges)](modules/02-linux-networking/) | 11-20 | [x] Done |
| 03 | [Linux Networking Advanced (tcpdump, eBPF)](modules/03-linux-networking-advanced/) | 21-30 | [x] Done (übrige Tage optional) |
| 04 | [Cilium: Up and Running — CCA Vorbereitung](modules/04-cilium/) | 31-62 | [~] In Progress (3/32) |

> Detaillierter Tagesplan für Modul 04 (inkl. Mini-Reviews und Mock Exams): siehe [CLAUDE.md](CLAUDE.md). Abgeschlossene Tage mit Learnings: [modules/progress.md](modules/progress.md).

## Module Structure

```
modules/XX-topic/
├── days/
│   ├── day-XX.md             # Aufgaben & Flashcards
│   └── day-XX_SOLUTION.md    # Lösung
├── flashcards/               # Flashcards pro Kapitel (Modul 04)
├── CCA-exam.md               # Exam-Notizen (Modul 04)
└── cheatsheets/              # z.B. rz_profi_tipps.md
```

## Tools (macOS)

```bash
# Network analysis
brew install wireshark nmap

# DNS
dig, nslookup, host  # pre-installed

# Network diagnostics
ping, traceroute, netstat, tcpdump  # pre-installed

# K8s lab (Module 04)
brew install kind kubectl helm
```

---

Co-Author: [Claude Code](https://claude.ai/code)
