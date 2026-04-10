# 100-Days Networking Challenge

Preparing for a RZ team transition. From zero to solid networking skills in 100 days.

## Sources

- **Primary:** Harald Zisler — *Computer-Netzwerke* (8th edition, 456 pages)
- **Deep Dive:** Peter Dordal — *Rechnernetze – Das umfassende Lehrbuch* (1st edition, 2023)
- **Systems Perspective:** Peterson & Davie — *Computer Networks: A Systems Approach*
- **Reference:** Tanenbaum & Wetherall — *Computer Networks* (5th edition)
- **Linux Networking:** LARTC — *Linux Advanced Routing & Traffic Control*

## Daily Routine

| When | What | Duration |
|------|------|----------|
| Mon-Fri | Reading assignment + flashcard review | ~25-30 min |
| Sat/Sun | Hands-on lab + review questions | ~45-60 min |

## Modules & Progress

> Ausgerichtet auf den RZ-Stack: RKE2, Cilium, MetalLB, HAProxy, Istio, VictoriaMetrics

| # | Module | Days | Status |
|---|--------|------|--------|
| 01 | [Grundlagen (OSI, TCP/IP, DNS)](modules/01-grundlagen/) | 1-10 | [x] Done |
| 02 | [Linux Networking (ip, netns, veth, bridges)](modules/02-linux-networking/) | 11-20 | [ ] |
| 03 | [Ethernet, IP & Subnetting](modules/03-ethernet-ip-subnetting/) | 21-30 | [ ] |
| 04 | [Routing & BGP (FRRouting)](modules/04-routing-bgp/) | 31-40 | [ ] |
| 05 | [TCP/UDP & DNS/CoreDNS](modules/05-tcp-dns/) | 41-50 | [ ] |
| 06 | [Load Balancing — HAProxy & MetalLB](modules/06-loadbalancing/) | 51-60 | [ ] |
| 07 | [K8s Networking Basics (CNI, Services, Ingress)](modules/07-k8s-basics/) | 61-70 | [ ] |
| 08 | [Cilium & eBPF](modules/08-cilium-ebpf/) | 71-80 | [ ] |
| 09 | [Service Mesh — Istio & OPA Gatekeeper](modules/09-istio-opa/) | 81-90 | [ ] |
| 10 | [Observability & End-to-End (VictoriaMetrics)](modules/10-observability/) | 91-100 | [ ] |

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
