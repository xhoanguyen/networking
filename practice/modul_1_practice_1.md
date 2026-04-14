# RZ-Wissenscheck Modul 01 — Practice 1

Schwierigkeitsgrade: ★ leicht | ★★ mittel | ★★★ schwer

---

## Theorie-Fragen

### Frage 1 — DNS vs. Routing ★

`ping google.com` liefert `cannot resolve host`, aber `ping 8.8.8.8` funktioniert.

- Was genau ist das Problem?
- Auf welcher TCP/IP-Schicht liegt es?
- Welchen Befehl nutzt du um den DNS-Resolver zu prüfen?

---

### Frage 2 — TCP vs. UDP im Monitoring ★★

Dein Monitoring meldet: "NTP-Server `ntp.rz.internal` Port 123 nicht erreichbar."
Du machst `telnet ntp.rz.internal 123` → "Connection refused."

- Ist der NTP-Server wirklich down? Begründe.
- Welches Tool wäre hier das richtige?

---

### Frage 3 — Schichtenweise Fehlersuche ★★

Ein Kollege meldet: "`monitor.rz.internal` ist down." Du sitzt im RZ-Netz mit einem Laptop.

Beschreibe deine Vorgehensweise von unten nach oben im TCP/IP-Modell:
- Welchen Befehl setzt du auf **jeder Schicht** ein?
- Was kannst du nach jedem **erfolgreichen** Check **ausschließen**?

---

### Frage 4 — Traceroute interpretieren ★★★

Du bekommst folgendes Ergebnis:

```
traceroute to app.rz.internal (10.0.5.42)
 1  192.168.1.1      1ms
 2  10.0.0.1         2ms
 3  * * *
 4  * * *
 5  * * *
```

- Bedeutet das **zwingend**, dass `10.0.5.42` nicht erreichbar ist?
- Was könnten die `* * *` sonst bedeuten?
- Was prüfst du als Nächstes?

---

### Frage 5 — Encapsulation im Paketfluss ★★★

Ein HTTP-GET-Request wird von deinem Laptop an `app.rz.internal` geschickt.

- Ordne die Begriffe **Frame, Paket, Segment, Message** den vier TCP/IP-Schichten zu.
- Erkläre, warum ein 100-Byte HTTP-Request am Kabel **mehr als 100 Byte** groß ist.
- Welche Schicht fügt die MAC-Adresse hinzu, und warum ändert sie sich bei jedem Hop?

---

## Praxis-Aufgaben am Terminal

### P1 — DNS-Auflösung manuell prüfen ★

Frag gezielt einen bestimmten DNS-Server, welche IP zu `cloudflare.com` gehört — nutze **nicht** den System-Resolver, sondern `dig` direkt gegen `1.1.1.1`. Dann vergleiche mit `8.8.8.8`.

```bash
dig @1.1.1.1 cloudflare.com
dig @8.8.8.8 cloudflare.com
```

**Notiere:**
- Welche IP(s) bekommst du zurück?
- Unterscheidet sich die TTL zwischen den beiden Resolvern?

---

### P2 — TCP-Handshake beobachten ★★

Öffne eine TCP-Verbindung zu `google.com:443` und vergleiche mit einem geschlossenen Port:

```bash
nc -vz google.com 443
nc -vz google.com 4242
```

**Notiere:**
- Welche Ausgabe bekommst du jeweils?
- Welches TCP-Verhalten (SYN → SYN-ACK → ACK vs. RST) liegt hinter den beiden Ergebnissen?

---

### P3 — Routing-Tabelle lesen und interpretieren ★★★

Zeig deine lokale Routing-Tabelle an:

```bash
netstat -rn
```

**Beantworte:**
- Welches ist deine **Default Route** und über welches Interface läuft sie?
- Welche Einträge sind **direkt erreichbar** (kein Gateway dazwischen)?
- Erkläre den Unterschied zwischen einem `link#`-Eintrag und einem Eintrag mit einer konkreten Gateway-IP.

> Lösungen: [modul_1_practice_1_solution.md](modul_1_practice_1_solution.md)
