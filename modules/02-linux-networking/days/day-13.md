# Tag 13 — Der `ip`-Befehl: Komplett-Training

## What are we doing today and why?

Heute geht es nur um einen einzigen Befehl: `ip`. Du wirst ihn so oft im RZ nutzen, dass er in Fleisch und Blut übergehen muss. Am Ende des Tages sollst du jedes Subcommand blind tippen können.

**Warum:** `ip` ersetzt `ifconfig`, `route`, `arp` und `netstat` — alles in einem Tool. Auf jedem RKE2-Node, jedem Container-Host, jedem Linux-Server ist `ip` dein erster Griff. Wer `ip` beherrscht, debuggt doppelt so schnell.

## Theorie: Aufbau des `ip`-Befehls

### Syntax

```
ip [OPTIONS] OBJECT COMMAND [ARGUMENTS]
```

| Teil | Bedeutung | Beispiele |
|------|-----------|----------|
| **OPTIONS** | Ausgabeformat, Farbe | `-c` (Farbe), `-br` (brief), `-4`/`-6` (IPv4/IPv6), `-j` (JSON) |
| **OBJECT** | Was willst du anschauen/ändern? | `link`, `addr`, `route`, `neigh`, `rule`, `tunnel`, `maddr` |
| **COMMAND** | Was tun? | `show`, `add`, `del`, `change`, `flush`, `get` |

### Die 6 wichtigsten Objects

| Object | Aufgabe | Altes Tool |
|--------|---------|------------|
| `ip link` | Interfaces verwalten (Layer 2) | `ifconfig` |
| `ip addr` | IP-Adressen verwalten (Layer 3) | `ifconfig` |
| `ip route` | Routing-Tabelle verwalten | `route` |
| `ip neigh` | ARP/Neighbor-Cache (Layer 2↔3) | `arp` |
| `ip rule` | Policy-Routing-Regeln | — |
| `ip monitor` | Änderungen live beobachten | — |

### Abkürzungen

`ip` erlaubt Abkürzungen solange sie eindeutig sind:

```bash
ip link show    = ip l show    = ip l s
ip addr show    = ip a show    = ip a s    = ip a
ip route show   = ip r show    = ip r s    = ip r
ip neigh show   = ip n show    = ip n s    = ip n
```

### Ausgabeformate

```bash
ip a                    # Standard-Ausgabe (ausführlich)
ip -br a                # Brief — eine Zeile pro Interface (★ für den Alltag)
ip -br -c a             # Brief + Farben (UP=grün, DOWN=rot)
ip -j a                 # JSON-Ausgabe (für Scripting mit jq)
ip -j -p a              # JSON, hübsch formatiert
ip -4 a                 # Nur IPv4
ip -6 a                 # Nur IPv6
ip -s link              # Statistics — Paketzähler, Errors, Drops
```

## 20 Terminal-Aufgaben

Alle Aufgaben in der Multipass-VM ausführen (`multipass shell rz-node`).
Markiere jede abgeschlossene Aufgabe mit ✅.

---

### Block A — Interfaces lesen (ip link)

**A1 ★** Zeige alle Interfaces im Brief-Format mit Farben an.

```bash
ip -br -c link show
```

- [ ] Welche Interfaces siehst du? Welche sind UP, welche DOWN?

---

**A2 ★** Zeige die Paket-Statistiken für `eth0` — wie viele Pakete wurden gesendet/empfangen, wie viele Fehler?

```bash
ip -s link show eth0
```

- [ ] Gibt es Errors oder Drops? (Bei einer frischen VM: sollten 0 sein)

---

**A3 ★★** Finde die MAC-Adresse deines `eth0`-Interfaces — nur mit `ip`, nicht mit `ifconfig`.

```bash
ip link show eth0 | grep ether
```

- [ ] Notiere die MAC-Adresse.

---

**A4 ★★** Setze das Interface `lo` auf DOWN, prüfe den Status, und setze es wieder auf UP.

```bash
# Achtung: lo deaktivieren bricht lokale Dienste!
sudo ip link set lo down
ip -br link show lo
sudo ip link set lo up
ip -br link show lo
```

- [ ] Was passiert mit dem Status? Was würde im RZ passieren wenn du `eth0` statt `lo` auf DOWN setzt?

---

### Block B — IP-Adressen verwalten (ip addr)

**B1 ★** Zeige alle IPv4-Adressen im Brief-Format.

```bash
ip -br -4 addr show
```

- [ ] Welche IPs hat deine VM?

---

**B2 ★★** Füge eine zweite IP-Adresse zu `eth0` hinzu, prüfe ob sie da ist, und entferne sie wieder.

```bash
sudo ip addr add 192.168.99.1/24 dev eth0
ip -br addr show eth0
sudo ip addr del 192.168.99.1/24 dev eth0
ip -br addr show eth0
```

- [ ] Hat `eth0` kurzzeitig zwei IPs gleichzeitig? (Ja — Linux erlaubt mehrere IPs pro Interface)

---

**B3 ★★** Zeige nur die IP-Adresse von `eth0` ohne den ganzen Rest — nutze dafür JSON + `jq`.

```bash
ip -j addr show eth0 | jq '.[0].addr_info[] | select(.family=="inet") | .local'
```

- [ ] Funktioniert das? Das ist die Basis für Scripting mit `ip`.

---

**B4 ★★★** Finde heraus welches Interface die IP `127.0.0.1` hat — ohne zu raten.

```bash
ip -br addr show | grep 127.0.0.1
```

- [ ] Auf welchem Interface liegt sie?

---

### Block C — Routing (ip route)

**C1 ★** Zeige deine Default Route. Welches Gateway und welches Interface?

```bash
ip route show default
```

- [ ] Gateway-IP und Interface notieren.

---

**C2 ★** Frage den Kernel: "Über welchen Weg würde ein Paket zu `8.8.8.8` gehen?"

```bash
ip route get 8.8.8.8
```

- [ ] Welches Interface, welches Gateway, welche Source-IP nennt der Kernel?

---

**C3 ★★** Füge eine statische Route hinzu: "Alles für `10.99.0.0/24` soll über deinen Gateway laufen." Prüfe und lösche sie wieder.

```bash
GATEWAY=$(ip route show default | awk '{print $3}')
sudo ip route add 10.99.0.0/24 via $GATEWAY
ip route show | grep 10.99
sudo ip route del 10.99.0.0/24
```

- [ ] Erscheint die Route in `ip route show`? Verschwindet sie nach `del`?

---

**C4 ★★** Zeige die `local`-Tabelle und finde deine eigene IP dort.

```bash
ip route show table local
```

- [ ] Warum steht deine IP mit `scope host` in der lokalen Tabelle?

---

**C5 ★★★** Zeige alle Policy-Routing-Regeln und erkläre die Reihenfolge.

```bash
ip rule show
```

- [ ] Was bedeuten die Prioritäten 0, 32766, 32767?
- [ ] Welche Tabelle wird zuerst konsultiert?

---

### Block D — ARP / Neighbor-Cache (ip neigh)

**D1 ★** Zeige den ARP-Cache und identifiziere deinen Gateway.

```bash
ip neigh show
```

- [ ] Welche IP-MAC-Paare siehst du? Welcher Eintrag ist dein Gateway?

---

**D2 ★★** Leere den ARP-Cache, pinge deinen Gateway, und beobachte wie der Eintrag zurückkommt.

```bash
sudo ip neigh flush all
ip neigh show
ping -c 1 $(ip route show default | awk '{print $3}')
ip neigh show
```

- [ ] Welchen Zustand hat der neue Eintrag? (`REACHABLE`?)

---

**D3 ★★** Füge einen statischen ARP-Eintrag hinzu und lösche ihn wieder.

```bash
sudo ip neigh add 192.168.99.99 lladdr aa:bb:cc:dd:ee:ff dev eth0
ip neigh show | grep 192.168.99
sudo ip neigh del 192.168.99.99 dev eth0
```

- [ ] In welchem Zustand ist der manuell hinzugefügte Eintrag? (`PERMANENT`?)

---

**D4 ★★★** Beobachte ARP in Echtzeit — öffne zwei Terminals:

```bash
# Terminal 1: ARP-Pakete live mitschneiden
sudo tcpdump -i eth0 arp -n -e

# Terminal 2: Cache leeren und Ping
sudo ip neigh flush all && ping -c 1 8.8.8.8
```

- [ ] Siehst du den ARP-Request (who-has) und die Reply? Welche MACs tauchen auf?

---

### Block E — Monitoring und Debugging (ip monitor)

**E1 ★★** Starte `ip monitor` in einem Terminal und ändere etwas in einem zweiten Terminal.

```bash
# Terminal 1: Live-Monitor
ip monitor all

# Terminal 2: IP hinzufügen und wieder entfernen
sudo ip addr add 10.42.42.1/24 dev eth0
sudo ip addr del 10.42.42.1/24 dev eth0
```

- [ ] Welche Events zeigt der Monitor? (Routing-Änderungen, Addr-Änderungen, Neigh-Änderungen)

---

**E2 ★★** Zeige die Interface-Statistiken für alle Interfaces und finde heraus welches Interface die meisten Pakete übertragen hat.

```bash
ip -s -s link show
```

- [ ] Welches Interface hat die meisten TX/RX Bytes?

---

**E3 ★★★** Baue einen Einzeiler, der die IP-Adresse deines Default-Gateways ausgibt — nur mit `ip` und `awk`:

```bash
ip route show default | awk '{print $3}'
```

Jetzt erweitere ihn: zeige die MAC-Adresse des Gateways:

```bash
ip neigh show $(ip route show default | awk '{print $3}') | awk '{print $5}'
```

- [ ] Funktionieren beide Einzeiler? Das sind typische Scripting-Patterns im RZ.

---

**E4 ★★★** Kombiniere alles: erstelle einen Mini-Netzwerk-Report mit einem einzigen Befehl:

```bash
echo "=== Interfaces ===" && ip -br -c link && \
echo "=== IPs ===" && ip -br -4 addr && \
echo "=== Default Route ===" && ip route show default && \
echo "=== Gateway MAC ===" && ip neigh show $(ip route show default | awk '{print $3}') && \
echo "=== DNS ===" && cat /etc/resolv.conf | grep nameserver
```

- [ ] Kopiere die Ausgabe und vergleiche sie mit dem was du an Tag 11 manuell zusammengetragen hast.

---

## Profi-Tipps für den RZ-Alltag

### 1. Deine täglichen 3 Befehle beim Login auf einen Node

Mach das zur Gewohnheit — immer wenn du dich auf einen Server einloggst:

```bash
ip -br -c a          # Welche IPs, welche Interfaces, was ist UP/DOWN?
ip r                  # Wohin geht Traffic? Default Gateway korrekt?
ss -tlnp              # Welche Services lauschen? (nicht ip, aber gehört dazu)
```

Diese drei Befehle dauern 2 Sekunden und geben dir sofort ein Bild vom Zustand des Servers.

### 2. Debug-Reihenfolge bei "Server nicht erreichbar"

```bash
# 1. Hat der Server überhaupt eine IP?
ip -br a

# 2. Ist das Interface UP?
ip -br link

# 3. Stimmt die Route?
ip route get <ziel-ip>

# 4. Kennt er den Gateway per ARP?
ip neigh show <gateway-ip>

# 5. Gibt es Paket-Drops auf dem Interface?
ip -s link show eth0 | grep -i "drop\|error"
```

### 3. Fehler finden mit `-s` (Statistics)

```bash
ip -s link show eth0
```

Achte auf diese Zeilen:

```
RX errors: 0  dropped: 0  overruns: 0
TX errors: 0  dropped: 0  carrier: 0
```

- **RX dropped > 0**: Interface-Buffer voll, zu viel Traffic für die NIC → braucht Ring-Buffer-Tuning oder schnellere NIC
- **TX errors > 0**: Kabel/Hardware-Problem, oder Duplex-Mismatch
- **carrier > 0**: Link flaps — Kabel wackelt oder Switch-Port hat Probleme

### 4. JSON-Output für Scripting

Im RZ automatisierst du vieles per Script. `ip -j` gibt JSON aus:

```bash
# IP-Adresse eines bestimmten Interfaces in eine Variable
MY_IP=$(ip -j addr show eth0 | jq -r '.[0].addr_info[] | select(.family=="inet") | .local')
echo $MY_IP

# Alle Interface-Namen als Liste
ip -j link show | jq -r '.[].ifname'

# Gateway-IP extrahieren
ip -j route show default | jq -r '.[0].gateway'
```

### 5. `ip monitor` als Live-Debugging-Tool

Wenn du nicht weißt warum sich Routen oder ARP-Einträge ändern:

```bash
# Alles beobachten
ip monitor all

# Nur Routing-Änderungen
ip monitor route

# Nur ARP-Änderungen (z.B. bei MetalLB-Failover)
ip monitor neigh

# Nur Link-Status (Kabel rein/raus, Interface up/down)
ip monitor link
```

Im RZ lässt du `ip monitor neigh` laufen während du MetalLB testest — du siehst sofort, wann ein Gratuitous ARP ankommt.

### 6. Typische Fehler und ihre Lösung

| Problem | Befehl | Was du siehst | Lösung |
|---------|--------|---------------|--------|
| Kein Netz nach Neustart | `ip -br a` | Interface hat keine IP | `sudo dhclient eth0` oder Netplan prüfen |
| Gateway nicht erreichbar | `ip neigh show <gw>` | `FAILED` | Falsches Subnetz oder Gateway down |
| Nur lokales Netz geht | `ip r` | Keine Default Route | `sudo ip route add default via <gw>` |
| Große Dateien hängen | `ping -M do -s 1472 <ziel>` | Timeout ab 1473 | MTU anpassen: `sudo ip link set eth0 mtu 1450` |
| Doppelte IP-Konflikte | `ip monitor neigh` | ARP-Einträge flappen | Duplicate IP im Netz finden: `arping -D <ip>` |

### 7. Alias für den Alltag

Füge das in deine `.bashrc` oder `.zshrc` ein:

```bash
alias ipa='ip -br -c addr'
alias ipl='ip -br -c link'
alias ipr='ip route'
alias ipn='ip neigh'
alias ips='ip -s link'
```

Dann reicht `ipa` statt `ip -br -c addr` — spart Sekunden die sich über den Tag summieren.

## Mini-Quiz

1. Was ist der Unterschied zwischen `ip link show` und `ip addr show`?
2. Du siehst `RX dropped: 1542` auf einem Interface. Was könnte die Ursache sein?
3. Wie fügst du eine temporäre IP-Adresse zu einem Interface hinzu, die einen Neustart nicht überlebt?
4. Welchen `ip`-Befehl nutzt du um in Echtzeit zu sehen, wann ein Kabel eingesteckt wird?

## Reflexion

- [ ] Kann ich blind `ip -br -c a` tippen?
- [ ] Kenne ich den Unterschied zwischen `ip link` (Layer 2) und `ip addr` (Layer 3)?
- [ ] Kann ich mit `ip route get` prüfen, welchen Weg ein Paket nehmen wird?
- [ ] Weiß ich wie `ip -j` und `jq` zusammen für Scripting funktionieren?
- [ ] Habe ich die Aliases in meine Shell-Config eingebaut?
