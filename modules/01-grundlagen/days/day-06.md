# Tag 6 — Wochenend-Review + Lab (Sa/So)

## Wiederholung (15 Min)

Geh alle Flashcards von Tag 1-5 durch. Markiere die, bei denen du unsicher bist.

**Schwerpunkte zum Wiederholen:**
- [ ] OSI 7 Schichten auswendig (mit Eselsbrücke)
- [ ] TCP/IP 4 Schichten und Mapping auf OSI
- [ ] PAN/LAN/MAN/WAN Unterschiede
- [ ] Paketorientierung erklären können

## Prüfungsfragen aus dem Buch

Aus Zisler Kap. 1.6 (S. 31):
1. Wann sind RFC-Dokumente verbindlich anzuwenden?
2. Sie verbinden auf einem Werksgelände mehrere Gebäude. Wie bezeichnen Sie ein derartiges Netzwerk?

> Lösungen: Anhang B im Zisler-Buch

## Lab: Netzwerk-Interfaces erkunden

**Ziel:** Die eigenen Netzwerk-Interfaces auf macOS kennenlernen.

### Aufgabe 1: Interfaces auflisten

```bash
# Alle Interfaces anzeigen
ifconfig

# Nur aktive Interfaces
ifconfig -a | grep "flags\|inet"

# macOS-spezifisch: Netzwerk-Dienste
networksetup -listallnetworkservices
```

**Notiere:**
- [ ] Wie heißt dein Ethernet-Interface? (z.B. en0)
- [ ] Wie heißt dein WLAN-Interface? (z.B. en1)
- [ ] Was ist deine aktuelle IP-Adresse?
- [ ] Was ist deine Subnetzmaske?

### Aufgabe 2: Gateway und DNS

```bash
# Standard-Gateway anzeigen
netstat -rn | grep default

# DNS-Server anzeigen
scutil --dns | grep nameserver
```

**Notiere:**
- [ ] Was ist dein Standard-Gateway?
- [ ] Welche DNS-Server verwendest du?

### Aufgabe 3: Verbindung testen

```bash
# Ping zum Gateway
ping -c 4 <dein-gateway>

# Ping ins Internet
ping -c 4 1.1.1.1

# DNS-Auflösung testen
ping -c 4 google.com
```

**Fragen zum Nachdenken:**
- Was passiert wenn du dein WLAN ausschaltest und den Ping wiederholst?
- Welche OSI-Schichten sind an einem erfolgreichen `ping` beteiligt?
