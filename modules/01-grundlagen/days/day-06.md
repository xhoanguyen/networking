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

### Antworten

**1. Leitungsvermittelt vs. Paketvermittelt**

- **Leitungsvermittelt:** Eine dedizierte Verbindung wird für die gesamte Kommunikation reserviert — exklusiv belegt, auch wenn gerade keine Daten fließen.
  - Beispiel: klassisches Telefonnetz (PSTN)
- **Paketvermittelt:** Daten werden in Pakete aufgeteilt, die unterschiedliche Wege nehmen können. Die Leitung wird gemeinsam genutzt (shared) — viel effizienter.
  - Beispiel: Internet (IP-basiert)

**2. Systematische Fehlersuche im TCP/IP-Modell (von unten nach oben)**

| Schicht | Prüfe | Werkzeug |
|---------|-------|----------|
| **Network Access** | Kabel, Link-Status | `ethtool eth0` |
| **Internet** | IP erreichbar? Route korrekt? | `ping` / `traceroute` |
| **Transport** | Port offen? TCP-Verbindung? | `telnet host 443` / `ss -tlnp` |
| **Application** | Antwortet der Dienst? | `curl` |

Praxis im RZ: Von unten starten — ein Kabelproblem macht alles darüber kaputt.

**3. Leaf-Spine vs. Stern-Topologie**

- **Stern:** Ein zentraler Switch → Single Point of Failure
- **Leaf-Spine:** Jeder Leaf-Switch ist mit jedem Spine-Switch verbunden → kein Single Point of Failure, immer genau 2 Hops, Bandbreite über alle Spines verteilt
- **Schleifen-Protokoll:** Spanning Tree Protocol (STP) blockiert redundante Layer-2-Pfade, um Broadcast-Schleifen zu verhindern. Modernere Variante: RSTP (Rapid STP)
- In modernen Leaf-Spine-Netzen wird oft Layer-3 Routing (z.B. BGP) statt STP genutzt, damit alle Pfade gleichzeitig nutzbar sind

## Abschlusstest Tag 1–6

### Theorie-Fragen

1. Nenne die 4 Schichten des TCP/IP-Modells und ordne jeder Schicht ein Protokoll zu, das du im RZ-Alltag antreffen würdest.
2. Ein Kollege sagt: "Der Ping geht, aber `curl` liefert einen Timeout." Auf welcher TCP/IP-Schicht liegt das Problem vermutlich — und warum kannst du die unteren Schichten ausschließen?
3. Was ist der Unterschied zwischen einem LAN und einem WAN? In welche Kategorie fällt die Verbindung zwischen zwei RZ-Standorten eurer Firma?
4. Erkläre den Encapsulation-Prozess: Was passiert mit einem HTTP-Request, wenn er von der Application-Schicht bis zum Kabel wandert? Nenne die Bezeichnung der Dateneinheit pro Schicht.
5. Warum hat der Ping zu `1.1.1.1` in deinem Lab einen niedrigeren TTL-Wert als der Ping zu deinem Gateway? Was sagt dir das über den Netzwerkpfad?
6. Ein neuer Server im RZ bekommt keine IP-Adresse. Nenne zwei mögliche Ursachen und mit welchem Befehl du jeweils prüfen würdest, ob das Problem dort liegt.

### Praktische Aufgaben

- **P1:** Finde heraus, wie viele Hops zwischen deinem Rechner und `1.1.1.1` liegen.
- **P2:** Prüfe, ob Port 443 auf `google.com` erreichbar ist — ohne Browser.
- **P3:** Zeige die ARP-Tabelle deines Rechners an und finde die MAC-Adresse deines Gateways.

### Antworten Theorie

**1.** Application (HTTP) — Transport (TCP/UDP) — Internet (IP) — Network Access (Ethernet) ✅

**2.** Ping nutzt ICMP (Internet-Schicht). Wenn Ping geht, funktionieren Internet- und Network-Access-Schicht. Problem liegt auf Transport- oder Application-Schicht (z.B. Port blockiert oder Dienst läuft nicht). ✅

**3.** LAN = lokales Netz (Gebäude), WAN = weltweit. RZ-Verbindung: MAN wenn gleiche Stadt, WAN wenn verschiedene Städte. ✅

**4.** _(offen — wird fortgesetzt)_

**5.** _(offen)_

**6.** _(offen)_

### Antworten Praxis

**P1–P3:** _(offen)_

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
