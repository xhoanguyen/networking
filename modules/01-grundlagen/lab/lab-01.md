# Lab 01 — Netzwerk-Interfaces erkunden (macOS)

**Dauer:** ~45-60 Min
**Voraussetzungen:** macOS, Terminal
**Ziel:** Die eigene Netzwerkumgebung verstehen und mit CLI-Tools navigieren

## Teil 1: Interfaces (15 Min)

```bash
# Alle Interfaces auflisten
ifconfig

# Aktive Interfaces mit IP-Adressen
ifconfig | grep -E "^[a-z]|inet "

# macOS Netzwerk-Dienste
networksetup -listallnetworkservices

# Details zu Wi-Fi
networksetup -getinfo Wi-Fi
```

**Dokumentiere:**
| Was | Wert |
|-----|------|
| Ethernet-Interface | |
| WLAN-Interface | |
| IP-Adresse | |
| Subnetzmaske | |
| Gateway | |
| DNS-Server | |

## Teil 2: Konnektivität testen (15 Min)

```bash
# Gateway erreichbar?
ping -c 4 $(netstat -rn | grep default | awk '{print $2}' | head -1)

# Internet erreichbar? (IP direkt, kein DNS nötig)
ping -c 4 1.1.1.1

# DNS funktioniert?
ping -c 4 google.com

# DNS-Auflösung inspizieren
dig google.com +short

# Welche DNS-Server sind konfiguriert?
scutil --dns | grep nameserver | head -5
```

**Fragen:**
- Was passiert wenn der Gateway-Ping funktioniert aber 1.1.1.1 nicht?
- Was passiert wenn 1.1.1.1 funktioniert aber google.com nicht?

## Teil 3: Route verfolgen (15 Min)

```bash
# Route zu einem Server
traceroute -m 15 google.com

# Route anzeigen
netstat -rn | head -20
```

**Dokumentiere:**
- Wie viele Hops bis google.com?
- Was ist der erste Hop? (Dein Router)
- Gibt es Hops mit hoher Latenz?

## Teil 4: Reflexion (10 Min)

Beantworte schriftlich:
1. Welche OSI-Schichten waren bei jeder Aufgabe beteiligt?
2. Was hast du über dein eigenes Netzwerk gelernt?
3. Was würdest du gerne als nächstes untersuchen?
