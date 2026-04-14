# RZ-Wissenscheck Modul 01 — Practice 2

Schwierigkeitsgrade: ★ leicht | ★★ mittel | ★★★ schwer

---

## Theorie-Fragen

### Frage 1 — OSI vs. TCP/IP ★

Nenne die 7 OSI-Schichten und ordne sie den 4 TCP/IP-Schichten zu. Warum hat sich TCP/IP in der Praxis durchgesetzt, obwohl OSI "vollständiger" ist?

---

### Frage 2 — TTL-Analyse ★

Du pingst drei Ziele und bekommst folgende TTL-Werte zurück:

| Ziel | TTL |
|------|-----|
| 192.168.1.1 | 64 |
| 10.0.5.42 | 61 |
| 8.8.8.8 | 117 |

- Wie viele Hops liegen jeweils zwischen dir und dem Ziel?
- Welches Betriebssystem läuft vermutlich auf `8.8.8.8`?

---

### Frage 3 — Congestion im RZ ★★

Nachts laufen Backup-Jobs. Morgens melden Kollegen: "Monitoring reagiert träge, manche Alerts kommen mit 30 Sekunden Verzögerung."

- Was ist die wahrscheinlichste Netzwerk-Ursache?
- Auf welcher Schicht liegt das Problem?
- Wie reagiert TCP automatisch darauf — und warum ist das gleichzeitig Teil des Problems?

---

### Frage 4 — ARP und MAC-Adressen ★★

Dein Server `10.0.1.5` will ein Paket an `10.0.2.42` schicken. Die beiden sind **nicht** im selben Subnetz. Der Gateway ist `10.0.1.1`.

- An welche **MAC-Adresse** schickt `10.0.1.5` den Frame?
- Warum nicht an die MAC von `10.0.2.42` direkt?
- Was passiert, wenn `10.0.1.5` die MAC des Gateways nicht kennt?

---

### Frage 5 — Mehrere Fehler gleichzeitig ★★★

Ein neuer Server im RZ hat folgendes Problem:
- `ip link show` → Interface `eth0` ist UP
- `ip addr show` → **keine IP-Adresse** auf `eth0`
- `ping 10.0.1.1` → "Network is unreachable"

Der Server soll seine IP per DHCP bekommen.

- Auf welcher TCP/IP-Schicht liegt das Problem?
- Nenne **drei** mögliche Ursachen, warum DHCP fehlschlägt.
- Welche Befehle nutzt du um jede Ursache zu prüfen?

---

## Praxis-Aufgaben am Terminal

### P1 — ARP-Tabelle untersuchen ★

Zeig deine ARP-Tabelle an und identifiziere deinen Gateway:

```bash
arp -a
```

**Notiere:**
- Welche IP hat dein Gateway und welche MAC-Adresse?
- Was bedeutet der Eintrag `ff:ff:ff:ff:ff:ff`?
- Pinge eine neue IP in deinem Netz (z.B. dein Handy) und prüfe ob ein neuer ARP-Eintrag erscheint.

---

### P2 — DNS-Kette nachvollziehen ★★

Verfolge die komplette DNS-Auflösung von `www.github.com` Schritt für Schritt:

```bash
# 1. Welche Nameserver sind für github.com zuständig?
dig NS github.com

# 2. Welche IP hat www.github.com?
dig A www.github.com

# 3. Ist www.github.com ein CNAME (Alias)?
dig CNAME www.github.com

# 4. Vollständige Auflösungskette anzeigen
dig +trace www.github.com
```

**Notiere:**
- Ist `www.github.com` ein direkter A-Record oder ein CNAME? Wohin zeigt er?
- Wie viele DNS-Server werden in der `+trace`-Ausgabe kontaktiert, bis du eine IP bekommst?

---

### P3 — Latenz-Vergleich und Hop-Analyse ★★★

Miss die Latenz zu drei verschiedenen Zielen und kombiniere mit Traceroute:

```bash
# Latenz messen (je 10 Pings)
ping -c 10 192.168.1.1
ping -c 10 1.1.1.1
ping -c 10 github.com

# Hops zählen
traceroute 1.1.1.1
traceroute github.com
```

**Analysiere:**
- Korreliert die Anzahl der Hops mit der Latenz?
- Gibt es Hops mit besonders hoher Latenz? Was könnte der Grund sein (ISP-Übergang, Landesgrenze)?
- Vergleiche die TTL-Werte der Ping-Antworten: welche Start-TTLs haben die Zielserver?

> Lösungen: [modul_1_practice_2_solution.md](modul_1_practice_2_solution.md)
