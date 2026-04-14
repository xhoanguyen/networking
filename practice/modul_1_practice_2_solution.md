# Lösungen — Practice 2

## Antworten Theorie

### Antwort 1 ★

| OSI-Schicht | Nr. | TCP/IP-Schicht |
|-------------|-----|----------------|
| Application | 7 | Application |
| Presentation | 6 | Application |
| Session | 5 | Application |
| Transport | 4 | Transport |
| Network | 3 | Internet |
| Data Link | 2 | Network Access |
| Physical | 1 | Network Access |

TCP/IP setzte sich durch, weil es nach dem Prinzip "rough consensus and running code" entwickelt wurde — es gab funktionierende Implementierungen (4.2BSD), bevor der Standard finalisiert war. OSI war ein Komitee-Produkt: erst spezifiziert, dann implementiert — als es fertig war, lief TCP/IP bereits überall.

---

### Antwort 2 ★

- **192.168.1.1:** TTL 64, Start-TTL = 64 → **0 Hops** (direkt im lokalen Netz, Linux/macOS)
- **10.0.5.42:** TTL 61, Start-TTL = 64 → **3 Hops** (Linux/macOS)
- **8.8.8.8:** TTL 117, Start-TTL = 128 → **11 Hops** (Windows oder Google-Infrastruktur)

Start-TTLs: Linux/macOS = 64, Windows/Google = 128. Formel: Start-TTL − empfangener TTL = Hops.

---

### Antwort 3 ★★

- **Ursache:** Congestion — die Backup-Jobs sättigen die Netzwerk-Links, Router-Queues laufen voll.
- **Schicht:** Transport (TCP Congestion Control) und Internet (Router-Queues).
- **TCP-Reaktion:** TCP erkennt Paketverlust und drosselt die Senderate (Congestion Control). Das **verhindert** einen Totalausfall — macht aber gleichzeitig **alle** TCP-Verbindungen auf denselben Links langsamer, auch Monitoring-Traffic. Die Backup-Jobs und das Monitoring konkurrieren um dieselbe Bandbreite.
- **RZ-Lösung:** Traffic-Priorisierung (QoS) — Monitoring-Traffic bekommt eine eigene Queue mit garantierter Bandbreite. Oder: Backup-Traffic auf ein separates Netz/VLAN legen.

---

### Antwort 4 ★★

- `10.0.1.5` schickt den Frame an die **MAC-Adresse des Gateways** (`10.0.1.1`), nicht an `10.0.2.42`.
- **Warum:** MAC-Adressen sind nur **lokal im selben Subnetz** gültig. `10.0.2.42` ist in einem anderen Subnetz — `10.0.1.5` kann dessen MAC per ARP nicht auflösen, weil ARP-Broadcasts das Subnetz nicht verlassen. Also muss das Paket an den Router (Gateway), der es weiterleitet.
- **Wenn die MAC des Gateways unbekannt ist:** `10.0.1.5` sendet einen **ARP-Request** (Broadcast: "Wer hat `10.0.1.1`?"). Der Gateway antwortet mit seiner MAC. Erst dann kann der Frame gebaut und gesendet werden. Ohne ARP-Antwort kann das Paket nicht zugestellt werden.

---

### Antwort 5 ★★★

- **Schicht:** Internet-Schicht — keine IP-Adresse = keine Teilnahme am IP-Netz.
- **Drei mögliche Ursachen:**

| Ursache | Prüf-Befehl |
|---------|-------------|
| 1. **Kein DHCP-Server erreichbar** (ausgefallen oder falsches VLAN) | `sudo dhclient -v eth0` (verbose, zeigt ob DHCPDISCOVER rausgeht und ob eine Antwort kommt) |
| 2. **DHCP-Pool erschöpft** (alle IPs vergeben) | `journalctl -u isc-dhcp-server` auf dem DHCP-Server — zeigt "no free leases" |
| 3. **Switch-Port im falschen VLAN** (DHCP-Broadcast erreicht den Server nicht) | `tcpdump -i eth0 port 67 or port 68` — prüfen ob DHCPDISCOVER das Interface verlässt und ob eine Antwort kommt |

Zusätzlich: `sudo nmap --script broadcast-dhcp-discover` zeigt ob überhaupt ein DHCP-Server im Segment antwortet.

---

## Antworten Praxis

### Antwort P1 ★

- Der Gateway hat typischerweise die erste IP im Subnetz (z.B. `192.168.1.1`) und eine eindeutige MAC-Adresse des Router-Herstellers.
- `ff:ff:ff:ff:ff:ff` ist die **Broadcast-MAC-Adresse** — Frames an diese Adresse werden an alle Geräte im lokalen Segment ausgeliefert (z.B. ARP-Requests, DHCP-Discover).
- Nach einem Ping zu einem neuen Ziel im lokalen Netz erscheint ein neuer ARP-Eintrag, weil dein Rechner zuerst per ARP die MAC auflösen musste.

### Antwort P2 ★★

- `www.github.com` ist typischerweise ein **CNAME** (Alias), der auf eine CDN-Domain zeigt (z.B. `github.github.io` oder eine Fastly-Adresse). Erst der CNAME wird in eine IP aufgelöst.
- Bei `+trace` kontaktiert dig: Root-Server (`.`) → `.com`-TLD-Server → `github.com`-Nameserver → Antwort. Mindestens **3-4 DNS-Server** in der Kette.
- **RZ-Relevanz:** Wenn ein CNAME auf einen CDN-Provider zeigt und dieser ausfällt, ist die Website nicht erreichbar — obwohl der eigene Server läuft. DNS-Indirektion hat Vorteile (Flexibilität) und Risiken (Abhängigkeit).

### Antwort P3 ★★★

- **Korrelation Hops/Latenz:** Tendenziell ja, aber nicht linear. Ein einzelner Hop über eine Seekabelstrecke (z.B. Europa → USA) kann 50ms+ kosten, während 5 lokale Hops im selben Datenzentrum unter 1ms bleiben.
- **Hohe Latenz an einzelnen Hops:** Typisch bei ISP-Übergängen (Peering Points) oder Landesgrenzen. Auch überlastete Router zeigen erhöhte Latenz.
- **TTL-Startwerte:** Gateway = 64 (Linux/macOS), `1.1.1.1` = 64 (Cloudflare/Linux), `github.com` = variabel (oft 64 oder 128 je nach CDN-Edge). Die Differenz zum empfangenen TTL ergibt die Hop-Anzahl.
