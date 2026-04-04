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

## Zusätzliche Prüfungsfragen (Tag 1–5)

1. Erklären Sie den Unterschied zwischen leitungsvermittelter und paketvermittelter Kommunikation. Nennen Sie je ein Beispiel.
2. Ein Server im RZ ist nicht erreichbar. Beschreiben Sie anhand des TCP/IP-Schichtenmodells (4 Schichten) eine systematische Vorgehensweise zur Fehlersuche — nennen Sie pro Schicht ein konkretes Werkzeug.
3. Ihre Leaf-Spine-Architektur im RZ basiert auf Mesh-Prinzipien. Erklären Sie, warum diese Topologie gegenüber einer klassischen Stern-Topologie Vorteile bei der Ausfallsicherheit bietet, und nennen Sie das Protokoll, das Schleifen in Layer-2-Netzen verhindert.

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

## Lab-Ergebnisse

### Interfaces (Aufgabe 1)
- Ethernet/WLAN-Interface: `en0`
- Aktuelle IP-Adresse: `192.168.1.48`
- Bridge-Interface: `bridge100` (VMs im Netz `192.168.2.x`)

### Gateway und DNS (Aufgabe 2)
- Standard-Gateway: `192.168.1.1` (Router, über `en0`)
- DNS-Server: `192.168.1.1` (Router leitet DNS-Anfragen weiter)

### Ping-Tests (Aufgabe 3)

| Ziel | Latenz (avg) | TTL | Was wird getestet |
|------|-------------|-----|-------------------|
| `192.168.1.1` (Router) | ~6ms | 64 | Lokales Netz — kein Gateway nötig |
| `1.1.1.1` (Cloudflare) | ~29ms | 57 | Internet per IP — Gateway + Routing |
| `google.com` (142.250.130.139) | ~37ms | 114 | Internet per Name — DNS + Gateway + Routing |

**Beobachtungen:**
- Latenz steigt mit Entfernung
- TTL sinkt pro Hop (64 → 57 → 114, wobei Google bei 128 startet)
- `google.com` wurde per DNS zu `142.250.130.139` aufgelöst bevor der Ping losging
- Ping nutzt ICMP (Schicht 3) — kein TCP/UDP, keine Anwendungsschicht
