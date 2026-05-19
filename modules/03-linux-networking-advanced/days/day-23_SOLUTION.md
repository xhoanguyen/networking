# Tag 23 — tcpdump SOLUTION

## Aufgabe 1 — Erster Capture

```bash
# Terminal 1
sudo tcpdump -nn -i br0

# Terminal 2
sudo ip netns exec ns-a ping -c3 10.9.0.20
```

**Was du siehst:**
```
09:42:47.071082 IP 10.9.0.10 > 10.9.0.20: ICMP echo request, id 9229, seq 1, length 64
09:42:47.071220 IP 10.9.0.20 > 10.9.0.10: ICMP echo reply, id 9229, seq 1, length 64
09:42:52.300939 ARP, Request who-has 10.9.0.10 tell 10.9.0.20, length 28
09:42:52.300963 ARP, Request who-has 10.9.0.20 tell 10.9.0.10, length 28
```

**Warum ICMP zuerst, ARP danach?**
Der ARP-Cache war durch den Setup-Test-Ping bereits gefüllt. ICMP konnte sofort gesendet werden.
ARP erscheint erst später wenn der Cache-Eintrag abläuft (~30-60s).

**Letzte Zeile nach Ctrl+C:**
```
X packets captured
X packets received by filter
0 packets dropped by kernel
```
`packets dropped by kernel` = 0 bedeutet kein Packet Loss im Capture.

---

## Aufgabe 2 — Filter nach Host

```bash
sudo tcpdump -nn -i br0 host 10.9.0.10 and host 10.9.0.20
```

Ping von ns-a nach ns-c (10.9.0.30) → **nichts sichtbar im Capture**.

**Warum?**
BPF filtert direkt im Kernel — Pakete die nicht beide Bedingungen erfüllen (`10.9.0.10` AND `10.9.0.20`) kommen nie in den tcpdump-Prozess. Der Traffic existiert trotzdem auf der Bridge — ein anderes tcpdump ohne Filter würde ihn sehen.

---

## Aufgabe 3 — Nur ARP sehen

```bash
sudo tcpdump -i br0 -nn arp
```

ARP-Tabelle leeren und Ping erzwingen:
```bash
sudo ip netns exec ns-a ip neigh flush all
sudo ip netns exec ns-a ping -c1 10.9.0.20
```

**Was du siehst — 4 ARP-Pakete:**
```
ARP, Request who-has 10.9.0.20 tell 10.9.0.10   ← ns-a fragt nach ns-b
ARP, Reply 10.9.0.20 is-at e2:ea:95:e8:4f:fb     ← ns-b antwortet
ARP, Request who-has 10.9.0.10 tell 10.9.0.20   ← ns-b fragt zurück
ARP, Reply 10.9.0.10 is-at b6:38:44:d0:36:bc     ← ns-a antwortet
```

**Bidirektionaler ARP-Handshake** — beide Seiten wollen die MAC des anderen bestätigen.

**Broadcast-MAC beim ARP-Request:** `ff:ff:ff:ff:ff:ff`

---

## Aufgabe 4 — Capture in Datei schreiben

```bash
# Capture starten (mit Timestamp im Dateinamen)
sudo tcpdump -nn -i br0 -w /tmp/capture_$(date +%Y%m%d_%H%M).pcap

# Traffic erzeugen (Terminal 2)
sudo ip netns exec ns-a ping -c3 10.9.0.20
sudo ip netns exec ns-a ping -c3 10.9.0.30

# Ctrl+C — Zusammenfassung erscheint
# 30 packets received by filter
# 0 packets dropped by kernel

# Datei auslesen — nur ICMP
sudo tcpdump -nn -r /tmp/capture_*.pcap icmp
```

**Vorteil `-w` im RZ:**
- Einmal capturen, beliebig oft mit verschiedenen Filtern analysieren
- Timestamps erhalten — wichtig für Tickets und Postmortems
- Datei an Kollegen schicken oder in Wireshark öffnen

---

## Aufgabe 5 — HTTP-Traffic im Klartext

```bash
# HTTP-Server in ns-c starten
sudo ip netns exec ns-c python3 -m http.server 8081 &

# Terminal 1 — tcpdump mit ASCII-Payload
sudo tcpdump -nn -i br0 port 8081 -A

# Terminal 2 — HTTP-Request
sudo ip netns exec ns-a curl http://10.9.0.30:8081/
```

**Was du im Capture siehst:**
```
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.12.3
Date: Tue, 19 May 2026 08:27:09 GMT
Content-type: text/html; charset=utf-8
Content-Length: 843
```

**Sicherheits-Implikation:** Jeder mit Zugang zum Node und tcpdump kann unverschlüsselten HTTP-Traffic mitlesen — Headers, Body, Credentials, alles. Deshalb TLS Pflicht, auch intern. In Kubernetes übernimmt Istio mTLS automatisch.

---

## Aufgabe 6 — MAC-Adressen im Ethernet-Header

```bash
sudo tcpdump -nn -e -i br0
```

Ping von ns-a nach ns-b:

```bash
sudo ip netns exec ns-a ping -c1 10.9.0.20
```

**Output — eine Zeile zerlegt:**
```
b6:38:44:d0:36:bc > e2:ea:95:e8:4f:fb, ethertype IPv4 (0x0800), length 98: 10.9.0.10 > 10.9.0.20: ICMP echo request
```

| Teil | Bedeutung |
|------|-----------|
| `b6:38:44:d0:36:bc` | Source-MAC (ns-a, hinter veth-a-br) |
| `e2:ea:95:e8:4f:fb` | Destination-MAC (ns-b, hinter veth-b-br) |
| `ethertype IPv4 (0x0800)` | L3-Protokoll |
| `10.9.0.10 > 10.9.0.20` | L3-Adressen |

**FDB-Vergleich:**
```bash
bridge fdb show br br0 | grep b6:38:44:d0:36:bc
# b6:38:44:d0:36:bc dev veth-a-br master br0

bridge fdb show br br0 | grep e2:ea:95:e8:4f:fb
# e2:ea:95:e8:4f:fb dev veth-b-br master br0
```

MACs im tcpdump stimmen exakt mit der Bridge-FDB überein — Source Learning in Aktion.

---

## Wichtigste Flags im Überblick

| Flag | Bedeutung |
|------|-----------|
| `-nn` | Kein DNS, keine Port-Namen |
| `-i br0` | Interface auswählen |
| `-A` | Payload als ASCII (gut für HTTP) |
| `-X` | Payload als Hex + ASCII |
| `-e` | Ethernet-Header anzeigen (MAC-Adressen) |
| `-w datei.pcap` | In Datei schreiben |
| `-r datei.pcap` | Aus Datei lesen |
| `-c 10` | Nur 10 Pakete, dann stoppen |

## BPF-Filter Kurzreferenz

```bash
host 10.0.0.1              # Traffic zu/von IP
src host 10.0.0.1          # nur VON dieser IP
dst host 10.0.0.1          # nur ZU dieser IP
port 80                    # nur Port 80
not port 22                # SSH ausblenden
host X and host Y          # zwischen zwei IPs
arp                        # nur ARP
icmp                       # nur ICMP
```
