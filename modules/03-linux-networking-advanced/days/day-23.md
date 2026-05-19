# Tag 23 — tcpdump (Paket-Analyse im RZ)

## Lernziel

tcpdump ist das wichtigste Diagnose-Werkzeug im RZ-Alltag. Nach diesem Tag kannst du
gezielt Traffic mitschneiden, filtern und auswerten — und weißt wann du welchen Filter brauchst.

---

## Netzwerk-Topologie

```
                    ┌─────────────────────────────────────────┐
                    │           br0 (10.9.0.1/24)             │
                    │                Bridge                    │
                    └──────┬──────────────┬──────────────┬────┘
                           │              │              │
                      veth-a-br       veth-b-br      veth-c-br
                           │              │              │
                      veth-a           veth-b         veth-c
                           │              │              │
                ┌──────────┴──┐  ┌────────┴────┐  ┌─────┴───────┐
                │    ns-a     │  │    ns-b     │  │    ns-c     │
                │ 10.9.0.10   │  │ 10.9.0.20   │  │ 10.9.0.30   │
                └─────────────┘  └─────────────┘  └─────────────┘
```

---

## Flashcards — erst durchgehen, dann Lab

**1. Auf welcher OSI-Schicht arbeitet tcpdump?**

L2 — direkt am Network Interface. Er sieht rohe Ethernet-Frames, bevor das OS sie verarbeitet.
Das Interface wird in den **promiscuous mode** versetzt — es akzeptiert auch Frames die nicht an seine MAC adressiert sind.

**2. Was ist BPF?**

Berkeley Packet Filter — das Filter-System hinter tcpdump. BPF-Programme laufen direkt im Kernel,
nur passende Pakete kommen in den Userspace. Kein unnötiger Overhead. Vorgänger von eBPF.

**3. Was macht `-nn`?**

`-n` = keine DNS-Auflösung (IPs bleiben IPs)
`-nn` = kein DNS + keine Port-Namen (Port 80 bleibt `80`, nicht `http`)
Ohne `-nn` macht tcpdump bei jedem Paket einen Reverse-DNS-Lookup — das erzeugt eigenen Traffic während du sniffst.

**4. Was ist der Unterschied zwischen `-i eth0` und `-i any`?**

- `-i eth0` → sniffe auf einem Interface — gezielt, weniger Rauschen
- `-i any` → sniffe auf allen Interfaces gleichzeitig — erste Orientierung

**5. BPF-Filter Operatoren**

```
host 10.0.0.1          → Traffic zu/von dieser IP
src host 10.0.0.1      → nur Traffic VON dieser IP
dst host 10.0.0.1      → nur Traffic ZU dieser IP
port 80                → nur Port 80
not port 22            → SSH ausblenden
host X and host Y      → Traffic zwischen zwei IPs
host X or port 80      → logisches OR
```

---

## Theorie

### Wie tcpdump intern funktioniert

```
Netzwerk-Interface
       ↓
   [BPF Filter] ← du gibst den Filter an
       ↓ (nur passende Pakete)
   Kernel-Buffer
       ↓
   tcpdump (Userspace)
       ↓
   Terminal-Output oder .pcap Datei
```

Ohne Filter: alle Pakete kommen durch — kann bei hochvolumigem Traffic den Buffer überlasten
und zu **Packet Loss** im Capture führen ("`X packets dropped by kernel`" in der Zusammenfassung).

### Wichtige Flags

| Flag | Bedeutung |
|------|-----------|
| `-nn` | Kein DNS, keine Port-Namen |
| `-i eth0` | Interface auswählen |
| `-i any` | Alle Interfaces |
| `-c 10` | Nur 10 Pakete capturen, dann stoppen |
| `-w datei.pcap` | In Datei schreiben (für Wireshark) |
| `-r datei.pcap` | Aus Datei lesen |
| `-v`, `-vv` | Mehr Detail im Output |
| `-S` | Absolute TCP-Sequenznummern |
| `-e` | Ethernet-Header (MAC-Adressen) anzeigen |
| `-X` | Payload als Hex + ASCII anzeigen |
| `-A` | Payload als ASCII anzeigen (gut für HTTP) |

---

## Lab

### Setup — Netzwerk-Umgebung

Wir bauen drei Namespaces hinter einer Bridge — gleiche Topologie wie Tag 22.

```bash
# Bridge
sudo ip link add br0 type bridge
sudo ip link set br0 up
sudo ip addr add 10.9.0.1/24 dev br0

# Namespace A
sudo ip netns add ns-a
sudo ip link add veth-a type veth peer name veth-a-br
sudo ip link set veth-a-br master br0
sudo ip link set veth-a-br up
sudo ip link set veth-a netns ns-a
sudo ip netns exec ns-a ip link set veth-a up
sudo ip netns exec ns-a ip addr add 10.9.0.10/24 dev veth-a
sudo ip netns exec ns-a ip route add default via 10.9.0.1

# Namespace B
sudo ip netns add ns-b
sudo ip link add veth-b type veth peer name veth-b-br
sudo ip link set veth-b-br master br0
sudo ip link set veth-b-br up
sudo ip link set veth-b netns ns-b
sudo ip netns exec ns-b ip link set veth-b up
sudo ip netns exec ns-b ip addr add 10.9.0.20/24 dev veth-b
sudo ip netns exec ns-b ip route add default via 10.9.0.1

# Namespace C — Web-Server
sudo ip netns add ns-c
sudo ip link add veth-c type veth peer name veth-c-br
sudo ip link set veth-c-br master br0
sudo ip link set veth-c-br up
sudo ip link set veth-c netns ns-c
sudo ip netns exec ns-c ip link set veth-c up
sudo ip netns exec ns-c ip addr add 10.9.0.30/24 dev veth-c
sudo ip netns exec ns-c ip route add default via 10.9.0.1
```

Verbindung testen:

```bash
sudo ip netns exec ns-a ping -c1 10.9.0.20
```

---

### Aufgabe 1 — Erster Capture

Starte tcpdump auf der Bridge und pinge gleichzeitig von ns-a nach ns-b.

Öffne zwei Terminals:

**Terminal 1:**
```bash
sudo tcpdump -nn -i br0
```

**Terminal 2:**
```bash
sudo ip netns exec ns-a ping -c3 10.9.0.20
```

Fragen:
- Was siehst du im Output? Welche Protokolle tauchen auf?
- Was kommt zuerst — ARP oder ICMP? Warum?
- Stoppe tcpdump mit `Ctrl+C`. Was steht in der letzten Zeile?

---

### Aufgabe 2 — Filter nach Host

Jetzt mit gezieltem Filter. Starte tcpdump nur für Traffic zwischen ns-a (10.9.0.10) und ns-b (10.9.0.20):

Wie lautet der Befehl?

*(Tip: BPF-Filter mit `host` und `and`)*

Pinge diesmal von ns-a nach ns-c (10.9.0.30) — erscheint dieser Traffic im Capture?

---

### Aufgabe 3 — Nur ARP sehen

Du willst verstehen wann die Bridge ARP-Requests flutet. Capture nur ARP-Traffic auf der Bridge.

Wie lautet der Filter?

Leere danach die ARP-Tabelle in ns-a:
```bash
sudo ip netns exec ns-a ip neigh flush all
```

Pinge von ns-a nach ns-b und beobachte den ARP-Handshake.

Fragen:
- Wie viele ARP-Pakete siehst du für einen einzelnen Ping?
- Was ist die Broadcast-MAC-Adresse in der ARP-Anfrage?

---

### Aufgabe 4 — Capture in Datei schreiben

Schreibe einen Capture in eine `.pcap` Datei mit Timestamp im Namen:

```bash
sudo tcpdump -nn -i br0 -w /tmp/capture_$(date +%Y%m%d_%H%M).pcap &
```

Erzeuge etwas Traffic (Ping von ns-a nach ns-b und ns-c), dann stoppe tcpdump:

```bash
fg
# Ctrl+C
```

Lies die Datei wieder ein und zeige nur ICMP-Traffic:

```bash
sudo tcpdump -nn -r /tmp/capture_*.pcap icmp
```

Fragen:
- Welchen Vorteil hat `-w` im RZ-Alltag?
- Wann würdest du eine `.pcap` Datei an einen Kollegen schicken?

---

### Aufgabe 5 — HTTP-Traffic analysieren

Starte einen einfachen HTTP-Server in ns-c:

```bash
sudo ip netns exec ns-c python3 -m http.server 8080 &
```

Starte tcpdump auf Port 8080 mit ASCII-Payload-Ausgabe:

Wie lautet der Befehl um Port 8080 zu filtern und den Payload lesbar anzuzeigen?

*(Tip: `-A` Flag)*

Dann HTTP-Request von ns-a:

```bash
sudo ip netns exec ns-a curl http://10.9.0.30:8080/
```

Fragen:
- Siehst du den HTTP-Request im Klartext?
- Was würde das im RZ bedeuten wenn dieser Traffic unverschlüsselt über das Netzwerk läuft?

---

### Aufgabe 6 — MAC-Adressen im Capture sehen

Zeige den Ethernet-Header (MAC-Adressen) im tcpdump-Output.

*(Tip: `-e` Flag)*

Capture einen Ping von ns-a nach ns-b. Notiere:
- Source-MAC
- Destination-MAC beim ARP-Request (Broadcast?)
- Source-MAC vs. `bridge fdb show br br0` — stimmt es überein?

---

### Aufräumen

```bash
# HTTP-Server stoppen
sudo kill $(pgrep -f "python3 -m http.server") 2>/dev/null

# Namespaces und Bridge löschen
sudo ip netns delete ns-a
sudo ip netns delete ns-b
sudo ip netns delete ns-c
sudo ip link delete br0
```

---

## Was wir in Tag 23 gemacht haben

**Konzepte:**
- tcpdump arbeitet auf **L2** — sieht rohe Ethernet-Frames, setzt Interface in promiscuous mode
- **BPF** (Berkeley Packet Filter) ist das Filter-System — läuft im Kernel, Vorgänger von eBPF
- `-nn` verhindert DNS-Lookups während des Captures — kein eigener Noise
- `packets dropped by kernel` = Buffer überlastet, Filter zu weit gesetzt

**Lab-Aufgaben:**
1. Erster Capture — ICMP vs. ARP beobachtet, ARP-Cache-Verhalten verstanden
2. BPF-Filter nach Host — Traffic der nicht matched verschwindet komplett im Kernel
3. Nur ARP — bidirektionalen Handshake live gesehen (4 Pakete für einen Ping)
4. Capture in `.pcap` Datei schreiben und mit Filter auslesen
5. HTTP-Traffic im Klartext mit `-A` gelesen — Sicherheits-Implikation verstanden
6. MAC-Adressen mit `-e` sichtbar gemacht und mit Bridge-FDB verglichen

---

## RZ Profi-Tipp

Im RZ startest du tcpdump fast nie ohne `-w`. Grund: der Terminal-Output läuft weg und ist nicht reproduzierbar. Mit `-w` hast du den vollständigen Beweis für ein Ticket oder Postmortem. Workflow im RZ:

```bash
# Capture starten (im Hintergrund)
sudo tcpdump -nn -i eth0 host <problem-ip> -w /tmp/incident_$(date +%Y%m%d_%H%M).pcap &

# Problem reproduzieren...

# Capture stoppen
fg && # Ctrl+C

# Analyse — erst Überblick
sudo tcpdump -nn -r /tmp/incident_*.pcap | head -50

# Dann gezielt filtern
sudo tcpdump -nn -r /tmp/incident_*.pcap tcp and port 443
```
