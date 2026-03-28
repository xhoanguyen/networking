# 100-Days Networking Challenge

Vorbereitung auf den Wechsel ins RZ-Team. Von Null auf solide Networking-Kenntnisse in 100 Tagen.

## Quellen

- **Hauptbuch:** Harald Zisler — *Computer-Netzwerke* (8. Auflage, 456 S.)
- **Vertiefung:** Peter Dordal — *Rechnernetze – Das umfassende Lehrbuch* (1. Auflage 2023)

## Tagesrhythmus

| Wann | Was | Dauer |
|------|-----|-------|
| Mo-Fr | Leseabschnitt + Flashcard-Review | ~25-30 Min |
| Sa/So | Hands-On Lab + Prüfungsfragen | ~45-60 Min |

## Module & Fortschritt

| # | Modul | Tage | Status |
|---|-------|------|--------|
| 01 | [Grundlagen, OSI, TCP/IP](modules/01-grundlagen/) | 1-10 | [ ] |
| 02 | [Netzwerktechnik (Kabel, WLAN, PoE)](modules/02-netzwerktechnik/) | 11-20 | [ ] |
| 03 | [Ethernet & Switching (STP, VLAN, SDN)](modules/03-ethernet-switching/) | 21-30 | [ ] |
| 04 | [IP-Adressierung & Subnetting](modules/04-ip-adressierung/) | 31-40 | [ ] |
| 05 | [Adressen-Praxis (DHCP, DNS, ARP)](modules/05-adressen-praxis/) | 41-50 | [ ] |
| 06 | [Routing (statisch, dynamisch, BGP)](modules/06-routing/) | 51-60 | [ ] |
| 07 | [TCP, UDP, Ports, Firewalls](modules/07-tcp-udp-firewalls/) | 61-70 | [ ] |
| 08 | [Anwendungsprotokolle (HTTP, SSH, TLS)](modules/08-anwendungsprotokolle/) | 71-78 | [ ] |
| 09 | [Netzwerkpraxis & Sicherheit](modules/09-netzwerkpraxis-sicherheit/) | 79-88 | [ ] |
| 10 | [K8s-Networking (CNI, CoreDNS, Ingress)](modules/10-k8s-networking/) | 89-100 | [ ] |

## Struktur pro Modul

```
modules/XX-thema/
├── days/          # Tages-Dateien mit Leseauftrag, Flashcards, Quiz
│   ├── day-XX.md
│   └── ...
├── flashcards.md  # Alle Flashcards des Moduls
└── lab/           # Wochenend-Praxisaufgaben
    └── lab-XX.md
```

## Tools (macOS)

```bash
# Netzwerk-Analyse
brew install wireshark nmap

# DNS
dig, nslookup, host  # vorinstalliert

# Netzwerk-Diagnose
ping, traceroute, netstat, tcpdump  # vorinstalliert

# K8s-Lab (Modul 10)
brew install kind kubectl helm
```
