# Lösungen — Practice 3

## Antworten Theorie

### Antwort 1 ★

- **Leitungsvermittlung:** Dedizierte Verbindung für die gesamte Kommunikation reserviert. Leitung ist exklusiv belegt, auch wenn keine Daten fließen. Beispiel: klassisches Telefonnetz (PSTN).
- **Paketvermittlung:** Daten werden in Pakete aufgeteilt, die unabhängig voneinander über verschiedene Wege laufen. Leitung wird geteilt. Beispiel: Internet.
- **Vorteil Leitungsvermittlung:** Garantierte Bandbreite und konstante Latenz (gut für Echtzeit-Sprache im alten Telefonnetz).
- **Vorteil Paketvermittlung:** Effizientere Nutzung der Leitungen (viele Verbindungen teilen sich die Bandbreite), und ausfallsicher (fällt ein Pfad aus, nehmen Pakete einen anderen Weg).
- **Im RZ:** Server kommunizieren in Bursts — ein Request braucht kurz viel Bandbreite, dann wieder nichts. Bei Leitungsvermittlung wäre die Leitung dazwischen reserviert aber ungenutzt. Paketvermittlung nutzt die teure RZ-Infrastruktur maximal aus.

---

### Antwort 2 ★★

- **a) `10.0.1.42`** → direkt über `eth0` (liegt im Netz `10.0.1.0/24`, direkt angeschlossen)
- **b) `10.0.5.10`** → an Next Hop `10.0.2.1` über `eth1` (Eintrag `10.0.5.0/24`)
- **c) `8.8.8.8`** → an Default Gateway `10.0.1.254` über `eth0` (kein spezifischer Eintrag, also Default Route `0.0.0.0/0`)
- **d) `10.0.2.1`** → direkt über `eth1` (liegt im Netz `10.0.2.0/24`, direkt angeschlossen)

**Merke:** Der Router prüft die Einträge vom **spezifischsten zum allgemeinsten** (longest prefix match). Die Default Route greift nur, wenn kein spezifischerer Eintrag passt.

---

### Antwort 3 ★★

- **Unterschiedliche IPs:** Cloudflare nutzt **Anycast + GeoDNS**. Der DNS-Resolver des Users wird nach Standort erkannt, und Cloudflare antwortet mit der IP des nächstgelegenen Edge-Servers. Frankfurt bekommt eine Frankfurter IP, Tokio eine Tokioter.
- **Cache Miss:** Der Edge-Server in Frankfurt stellt einen Request an den **Origin-Server** (der echte Server der Firma), cached die Antwort, und liefert sie aus. Zukünftige Requests werden direkt vom Edge bedient, bis der Cache abläuft (TTL).
- **Cloudflare-Ausfall:** Die DNS-Records zeigen auf Cloudflare-IPs. Wenn Cloudflare down ist, sind diese IPs nicht erreichbar — obwohl der Origin-Server läuft. **Der Origin ist nur über die CDN-IPs erreichbar**, wenn kein direkter DNS-Fallback konfiguriert ist. Das ist ein reales Risiko bei CDN-Abhängigkeit.

---

### Antwort 4 ★★

Regeln werden **von oben nach unten** geprüft, erste Regel die passt gewinnt:

- **a) HTTPS aus dem Internet → ERLAUBT** (Regel 1: TCP, 0.0.0.0/0 → 443)
- **b) SSH aus 10.0.2.0/24 → ERLAUBT** (Regel 2: TCP, 10.0.0.0/8 → 22 — `10.0.2.x` liegt in `10.0.0.0/8`)
- **c) SSH aus dem Internet → BLOCKIERT** (Regel 2 matcht nicht, da Quell-IP nicht in `10.0.0.0/8`. Keine andere Regel erlaubt TCP/22. Default DENY greift)
- **d) DNS-Abfrage aus 10.0.1.0/24 → ERLAUBT** (Regel 3: UDP, 10.0.1.0/24 → 53)
- **e) Ping aus dem Internet → BLOCKIERT** (Ping = ICMP, keine Regel erlaubt ICMP. Default DENY greift)

---

### Antwort 5 ★★★

**Systematische Analyse:**

1. **Network Access:** Nicht das Problem — SSH funktioniert, also ist die physische Verbindung da.
2. **Internet:** Nicht das Problem — Ping und SSH funktionieren, IP-Routing ist intakt.
3. **Transport:** **Hier liegt das Problem** — Port 443 ist CLOSED. TCP-Handshake schlägt fehl.
4. **Application:** Kann nicht geprüft werden, da Transport schon fehlschlägt.

**Drei mögliche Root Causes:**

| Nr. | Ursache | Prüf-Befehl |
|-----|---------|-------------|
| 1 | **Webserver-Prozess ist abgestürzt** (nginx/Apache nicht gestartet) | `systemctl status nginx` / `ps aux \| grep nginx` |
| 2 | **Port-Konfiguration geändert** (Webserver lauscht auf anderem Port) | `ss -tlnp \| grep 443` — zeigt ob ein Prozess auf 443 lauscht |
| 3 | **Host-Firewall (iptables/nftables) blockiert Port 443** | `iptables -L -n` / `nft list ruleset` |

**Reihenfolge:** Erst `ss -tlnp` (schnellster Check — lauscht überhaupt etwas auf 443?), dann `systemctl status` (warum nicht?), dann Firewall (falls Prozess läuft aber Port trotzdem zu). Da beide Server gleichzeitig betroffen sind: vermutlich ein gemeinsames Deployment oder Config-Management (Ansible/Puppet) das einen Fehler pushed hat.

---

## Antworten Praxis

### Antwort P1 ★

- Typische lauschende Dienste: SSH (22), DNS-Stub (53 auf 127.0.0.53), Webserver (80/443), Docker (2375).
- **`0.0.0.0` (alle Interfaces):** Der Dienst ist von außen erreichbar — jeder im Netzwerk kann sich verbinden. Sicherheitsrisiko wenn nicht beabsichtigt.
- **`127.0.0.1` (nur lokal):** Der Dienst akzeptiert nur Verbindungen vom eigenen Rechner. Sicher, aber nicht von außen nutzbar.
- **RZ-Regel:** Ein Dienst sollte nur auf den Interfaces lauschen, auf denen er gebraucht wird. Ein Datenbankserver sollte nie auf `0.0.0.0` lauschen, sondern nur auf dem internen Netz-Interface.

### Antwort P2 ★★

| Schicht | Was du siehst | Relevante Adressen |
|---------|--------------|-------------------|
| **Network Access** | ARP-Eintrag des Gateways | MAC-Adresse des Routers |
| **Internet** | Traceroute-Hops, IP-Adressen | Quell-IP (deine), Ziel-IP (example.com) |
| **Transport** | `nc` meldet "succeeded" auf Port 80 | Quell-Port (zufällig), Ziel-Port (80) |
| **Application** | `dig` zeigt DNS-Auflösung, `curl` zeigt HTTP-Header | Hostname, HTTP-Statuscode, Server-Header |

Die MAC-Adresse ist nur für den ersten Hop relevant (dein Rechner → Gateway). Ab dem Gateway zählt nur noch die IP. Der Hostname wird nur von DNS und HTTP genutzt — auf dem Kabel reisen nur IPs.

### Antwort P3 ★★★

- **DNS-Zeit:** Typischerweise 10-50ms für einen uncached Lookup. Bei cached Einträgen (lokaler Resolver) unter 1ms.
- **Mit `--resolve`:** DNS-Lookup entfällt komplett (`time_namelookup` ≈ 0). Der Request wird messbar schneller — zeigt wie viel Zeit DNS normalerweise kostet.
- **Unerreichbarer DNS-Server:** `dig` wartet standardmäßig **5 Sekunden** pro Versuch, macht **3 Versuche** = bis zu **15 Sekunden Timeout**. In dieser Zeit hängt jede Anwendung, die DNS braucht. Das ist der Grund warum DNS-Ausfälle sich wie Totalausfälle anfühlen, obwohl die eigentlichen Services laufen.
