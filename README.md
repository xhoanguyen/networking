# 100-Days Networking Challenge

Preparing for a RZ team transition. From zero to solid networking skills in 100 days.

## Sources

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
| 02 | [Linux Networking (ip, netns, veth, bridges)](modules/02-linux-networking/) | 11-20 | [~] In Progress (19/20) |
| 03+ | Themen werden nach Tag 20 Final Exam festgelegt | 21-100 | [ ] |

### Themenpool ab Modul 03

> Reihenfolge und Einteilung folgt nach ehrlicher Lückenanalyse aus Tag 20.

VLANs · Bonding/LACP · tcpdump · eBPF · VXLAN · Cilium · MetalLB · Istio · Kubernetes Netzwerk-Debugging

## Module Structure

```
modules/XX-topic/
├── days/
│   ├── day-XX.md             # Aufgaben & Flashcards
│   └── day-XX_SOLUTION.md    # Lösung
├── flashcards.md
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

# K8s lab (Module 10)
brew install kind kubectl helm
```

---

Co-Author: [Claude Code](https://claude.ai/code)
