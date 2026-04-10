# 100-Days Networking Challenge

Preparing for a RZ team transition. From zero to solid networking skills in 100 days.

## Sources

- **Primary:** Harald Zisler — *Computer-Netzwerke* (8th edition, 456 pages)
- **Deep Dive:** Peter Dordal — *Rechnernetze – Das umfassende Lehrbuch* (1st edition, 2023)

## Daily Routine

| When | What | Duration |
|------|------|----------|
| Mon-Fri | Reading assignment + flashcard review | ~25-30 min |
| Sat/Sun | Hands-on lab + review questions | ~45-60 min |

## Modules & Progress

| # | Module | Days | Status |
|---|--------|------|--------|
| 01 | [Fundamentals, OSI, TCP/IP](modules/01-grundlagen/) | 1-10 | [x] Done |
| 02 | [Network Technology (Cables, WLAN, PoE)](modules/02-netzwerktechnik/) | 11-20 | [ ] |
| 03 | [Ethernet & Switching (STP, VLAN, SDN)](modules/03-ethernet-switching/) | 21-30 | [ ] |
| 04 | [IP Addressing & Subnetting](modules/04-ip-adressierung/) | 31-40 | [ ] |
| 05 | [Addressing in Practice (DHCP, DNS, ARP)](modules/05-adressen-praxis/) | 41-50 | [ ] |
| 06 | [Routing (Static, Dynamic, BGP)](modules/06-routing/) | 51-60 | [ ] |
| 07 | [TCP, UDP, Ports, Firewalls](modules/07-tcp-udp-firewalls/) | 61-70 | [ ] |
| 08 | [Application Protocols (HTTP, SSH, TLS)](modules/08-anwendungsprotokolle/) | 71-78 | [ ] |
| 09 | [Network Practice & Security](modules/09-netzwerkpraxis-sicherheit/) | 79-88 | [ ] |
| 10 | [K8s Networking (CNI, CoreDNS, Ingress)](modules/10-k8s-networking/) | 89-100 | [ ] |

## Module Structure

```
modules/XX-topic/
├── days/          # Daily files with reading assignments, flashcards, quizzes
│   ├── day-XX.md
│   └── ...
├── flashcards.md  # All flashcards for the module
└── lab/           # Weekend hands-on exercises
    └── lab-XX.md
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
