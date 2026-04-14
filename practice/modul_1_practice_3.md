# RZ-Wissenscheck Modul 01 — Practice 3

Schwierigkeitsgrade: ★ leicht | ★★ mittel | ★★★ schwer

---

## Theorie-Fragen

### Frage 1 — Paketvermittlung vs. Leitungsvermittlung ★

Ein Kollege fragt: "Warum nutzt das Internet nicht einfach feste Leitungen wie das alte Telefonnetz? Wäre das nicht zuverlässiger?"

- Erkläre den Unterschied zwischen den beiden Ansätzen.
- Nenne je einen Vorteil von Leitungsvermittlung und Paketvermittlung.
- Warum ist Paketvermittlung im RZ-Kontext besser geeignet?

---

### Frage 2 — Routing-Tabelle lesen ★★

Ein Router hat folgende Routing-Tabelle:

```
Ziel-Netz          Next Hop        Interface
10.0.1.0/24        direkt          eth0
10.0.2.0/24        direkt          eth1
10.0.5.0/24        10.0.2.1        eth1
0.0.0.0/0          10.0.1.254      eth0
```

Wohin schickt der Router ein Paket mit Ziel-IP:
- a) `10.0.1.42`
- b) `10.0.5.10`
- c) `8.8.8.8`
- d) `10.0.2.1`

---

### Frage 3 — CDN und DNS zusammen ★★

Ein User in Frankfurt ruft `app.firma.de` auf. Der DNS-Record zeigt auf einen CDN-Provider (Cloudflare). Erkläre:

- Warum bekommt der User in Frankfurt eine **andere IP** als ein User in Tokio?
- Was passiert mit dem Request, wenn der CDN-Edge in Frankfurt die Seite **nicht im Cache** hat?
- Was passiert, wenn Cloudflare einen **globalen Ausfall** hat, obwohl der Origin-Server läuft?

---

### Frage 4 — Firewall-Regeln verstehen ★★

Ein Server hat folgende Firewall-Regeln (vereinfacht):

```
ALLOW  TCP  0.0.0.0/0  → Port 443 (HTTPS)
ALLOW  TCP  10.0.0.0/8 → Port 22  (SSH)
ALLOW  UDP  10.0.1.0/24 → Port 53  (DNS)
DENY   ALL  0.0.0.0/0  → ALL
```

Was passiert bei folgenden Verbindungsversuchen?
- a) Ein User aus dem Internet öffnet `https://server.firma.de`
- b) Ein Admin im Netz `10.0.2.0/24` verbindet sich per SSH
- c) Ein Admin aus dem Internet versucht SSH
- d) Ein Server im Netz `10.0.1.0/24` macht eine DNS-Abfrage (UDP/53)
- e) Ein User aus dem Internet pingt den Server

---

### Frage 5 — Incident-Szenario ★★★

Montag morgen, 08:02. Das Monitoring zeigt:

```
08:00  app-server-01  HTTP Health Check FAILED (Timeout)
08:00  app-server-02  HTTP Health Check FAILED (Timeout)
08:00  db-server-01   Ping OK
08:01  app-server-01  SSH OK (von Jump-Host)
08:01  app-server-02  SSH OK (von Jump-Host)
08:01  app-server-01  Port 443 CLOSED
08:01  app-server-02  Port 443 CLOSED
```

- Auf welcher TCP/IP-Schicht liegt das Problem? Begründe systematisch.
- Nenne **drei** mögliche Root Causes.
- In welcher Reihenfolge würdest du die Ursachen prüfen und mit welchen Befehlen?

---

## Praxis-Aufgaben am Terminal

### P1 — Welche Ports sind offen? ★

Finde heraus, welche TCP-Ports auf deinem eigenen Rechner gerade offen sind und lauschen:

```bash
# macOS
lsof -i -P -n | grep LISTEN

# Linux
ss -tlnp
```

**Notiere:**
- Welche Dienste lauschen auf welchen Ports?
- Gibt es Dienste, die auf `0.0.0.0` lauschen (alle Interfaces) vs. `127.0.0.1` (nur lokal)? Was ist der Sicherheitsunterschied?

---

### P2 — HTTP-Request Schicht für Schicht ★★

Führe einen HTTP-Request durch und beobachte dabei jede TCP/IP-Schicht:

```bash
# 1. DNS-Auflösung (Application)
dig example.com

# 2. Route zum Ziel (Internet)
traceroute -m 5 example.com

# 3. TCP-Verbindung prüfen (Transport)
nc -vz example.com 80

# 4. HTTP-Request senden (Application)
curl -v http://example.com 2>&1 | head -25

# 5. ARP: Welche MAC wird für den ersten Hop genutzt? (Network Access)
arp -a | grep $(netstat -rn | grep default | awk '{print $2}' | head -1)
```

**Dokumentiere** für jede Schicht: Was hast du gesehen? Welche Adressen (MAC, IP, Port, Hostname) sind auf welcher Schicht relevant?

---

### P3 — Netzwerk-Incident simulieren ★★★

Simuliere einen DNS-Ausfall und beobachte die Auswirkungen:

```bash
# 1. Normaler Zustand: DNS funktioniert
curl -w "DNS: %{time_namelookup}s, Connect: %{time_connect}s, Total: %{time_total}s\n" \
     -o /dev/null -s https://example.com

# 2. DNS umgehen: direkt per IP + Host-Header
curl -w "DNS: %{time_namelookup}s, Connect: %{time_connect}s, Total: %{time_total}s\n" \
     -o /dev/null -s --resolve example.com:443:$(dig +short example.com | head -1) \
     https://example.com

# 3. Falschen DNS-Server befragen (simuliert DNS-Ausfall)
dig @192.0.2.1 example.com
```

**Analysiere:**
- Wie viel Zeit entfällt auf DNS vs. TCP-Connect vs. Gesamtzeit?
- Was passiert wenn du DNS umgehst (`--resolve`)? Wird der Request schneller?
- Was passiert bei einem unerreichbaren DNS-Server? Wie lange dauert der Timeout?

> Lösungen: [modul_1_practice_3_solution.md](modul_1_practice_3_solution.md)
