# Lösungen — Practice 1

## Antworten Theorie

### Antwort 1 ★

- **Problem:** DNS-Auflösung funktioniert nicht, aber IP-Konnektivität ist intakt.
- **Schicht:** Application-Schicht (DNS ist ein Application-Layer-Protokoll, auch wenn es über UDP/53 transportiert wird).
- **Prüfen:**
  ```bash
  # Welcher DNS-Server ist konfiguriert?
  scutil --dns | grep nameserver     # macOS
  cat /etc/resolv.conf               # Linux

  # DNS direkt testen
  dig @192.168.1.1 google.com        # lokalen Resolver testen
  dig @8.8.8.8 google.com            # externen Resolver als Vergleich
  ```
- **Häufige Ursachen:** DNS-Server ausgefallen, falsche `/etc/resolv.conf`, Firewall blockt UDP/53 zum Resolver.

---

### Antwort 2 ★★

- **Nein**, `telnet` testet **TCP-Verbindungen** — aber NTP läuft auf **UDP** Port 123. Ein "Connection refused" bei TCP sagt nichts über einen UDP-Dienst aus.
- **Richtiges Tool:**
  ```bash
  ntpq -p ntp.rz.internal          # NTP-spezifisch
  nc -vzu ntp.rz.internal 123      # generisch UDP-Port testen
  ```
- **Merkregel:** Immer prüfen welches Transportprotokoll ein Dienst nutzt, bevor man ein Diagnose-Tool wählt. TCP-Tools (telnet, curl) finden UDP-Services nie.

---

### Antwort 3 ★★

| Schicht | Befehl | Check | Bei Erfolg ausgeschlossen |
|---------|--------|-------|--------------------------|
| **Network Access** | `ip link show` / `ethtool eth0` | Link-Status UP? Kabel drin? | Physische Verbindung |
| **Internet** | `ping monitor.rz.internal` (oder IP direkt) | IP erreichbar? | Routing, IP-Konfiguration |
| **Transport** | `nc -vz monitor.rz.internal 443` | Port offen? TCP-Handshake? | Firewall-Block, Dienst-Port |
| **Application** | `curl -v https://monitor.rz.internal` | HTTP-Antwort? Statuscode? | Applikation selbst |

**Merke:** Immer von unten nach oben — ein Kabelproblem macht alles darüber kaputt.

---

### Antwort 4 ★★★

- **Nein**, `* * *` heißt **nicht zwingend** dass der Server unerreichbar ist.
- `* * *` bedeutet nur: der **Router an diesem Hop antwortet nicht auf Traceroute-Probes** (ICMP Time Exceeded). Viele Router/Firewalls unterdrücken ICMP-Antworten — aus Sicherheitsgründen.
- **Nächste Schritte:**
  ```bash
  ping 10.0.5.42
  nc -vz 10.0.5.42 443
  curl -v http://10.0.5.42
  ```
  Wenn diese Tests funktionieren, ist der Server erreichbar — die Router dazwischen antworten nur nicht auf Traceroute.

---

### Antwort 5 ★★★

| TCP/IP-Schicht | Dateneinheit | Was wird hinzugefügt |
|----------------|-------------|---------------------|
| **Application** | Message (Daten) | HTTP-Header + Body |
| **Transport** | Segment | TCP-Header (20 Byte: Ports, Seq-Nr, Flags) |
| **Internet** | Paket | IP-Header (20 Byte: Quell-IP, Ziel-IP, TTL) |
| **Network Access** | Frame | MAC-Header (14 Byte) + CRC-Trailer (4 Byte) |

- Ein 100-Byte HTTP-Request wird am Kabel ca. **158 Byte** groß: 100 (Daten) + 20 (TCP) + 20 (IP) + 14 (Ethernet-Header) + 4 (CRC) = 158 Byte. Jede Schicht fügt ihren eigenen Header hinzu — das ist **Encapsulation**.
- Die **MAC-Adresse** wird von der Network-Access-Schicht hinzugefügt. Sie ändert sich bei **jedem Hop**, weil MAC-Adressen nur lokal (im selben LAN-Segment) gelten. Der Router ersetzt die Source-MAC (seine eigene) und die Destination-MAC (nächster Hop), während Quell- und Ziel-IP gleich bleiben.

---

## Antworten Praxis

### Antwort P1 ★

- `dig @1.1.1.1 cloudflare.com` zeigt die A-Records (IPs) und die verbleibende Cache-TTL.
- Die TTLs können sich unterscheiden, da Cloudflare und Google jeweils eigene DNS-Caches mit unterschiedlichem Alter haben.
- Mehrere IPs = Load Balancing / CDN — Cloudflare verteilt Traffic über mehrere Edge-Server.

### Antwort P2 ★★

- **Port 443:** `Connection to google.com port 443 [tcp/https] succeeded!` — TCP-Handshake (SYN → SYN-ACK → ACK) war erfolgreich.
- **Port 4242:** `Connection refused` oder Timeout — der Server hat entweder mit RST geantwortet (Port zu, kein Dienst) oder gar nicht (Firewall dropped das SYN).
- **Unterschied:** Bei "refused" kam ein RST zurück (schnell), bei Timeout wurde das SYN still gedroppt (langsam, du wartest bis nc aufgibt).

### Antwort P3 ★★★

- **Default Route:** Der Eintrag `default` oder `0.0.0.0` — zeigt den Gateway und das Interface (z.B. `192.168.1.1` über `en0`). Bedeutet: "alles was ich nicht kenne, schick hierhin."
- **Direkt erreichbar:** Einträge mit `link#` als Gateway (macOS) oder ohne Gateway-IP. Das sind Netze, die direkt am Interface anliegen — kein Routing nötig, nur ARP.
- **`link#` vs. Gateway-IP:** `link#` = "dieses Netz hängt direkt an meinem Interface, ich kann Hosts per ARP direkt erreichen." Gateway-IP = "ich muss das Paket an diesen Router weiterleiten, der es für mich routet."
