# FAQ — Tag 13: Der `ip`-Befehl

---

## Warum `ip` statt `ifconfig`?

`ip` ersetzt `ifconfig`, `route`, `arp` und `netstat` — alles in einem Tool. Auf jedem Linux-System (RKE2-Node, Container-Host, normaler Server) ist `ip` dein erster Griff beim Debuggen. Wer `ip` beherrscht, debuggt doppelt so schnell.

---

## Syntax

```
ip [OPTIONS] OBJECT COMMAND [ARGUMENTS]
```

### OPTIONS — Ausgabeformat steuern

| Option | Bedeutung |
|--------|-----------|
| `-br` | Brief — eine Zeile pro Interface |
| `-c` | Farben (UP = grün, DOWN = rot) |
| `-4` / `-6` | Nur IPv4 oder nur IPv6 |
| `-j` | JSON-Output für Scripting mit `jq` |
| `-s` | Statistics — Paketzähler, Errors, Drops |

### Abkürzungen

`ip` erlaubt Abkürzungen solange sie eindeutig sind:

```bash
ip link show  =  ip l s  =  ip l
ip addr show  =  ip a
ip route show =  ip r
ip neigh show =  ip n
```

---

## Die 6 Objects im Detail

---

### 1. `ip link` — Interfaces auf Layer 2

Layer 2 = kein IP, nur Hardware. Hier siehst du MAC-Adressen, Interface-Status, MTU und ob ein Kabel steckt.

```bash
ip link show           # alle Interfaces
ip link show eth0      # nur eth0
ip -br -c link         # brief + Farben ← Alltags-Befehl
ip -s link show eth0   # Statistiken: RX/TX, Errors, Drops
```

**Beispielausgabe:**
```
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    link/ether aa:bb:cc:dd:ee:ff brd ff:ff:ff:ff:ff:ff
```

**Die 4 häufigsten Flags:**

| Flag | Bedeutung |
|------|-----------|
| `UP` | Interface ist **administrativ aktiviert** — Software-Entscheidung |
| `LOWER_UP` | **Physisches Signal da** — Kabel steckt, Hardware-Realität |
| `BROADCAST` | Interface unterstützt Broadcast — kann Pakete an alle im Subnetz senden |
| `MULTICAST` | Interface unterstützt Multicast — kann Pakete an Gruppen senden (z.B. für Routing-Protokolle wie OSPF) |

> `UP` vs `LOWER_UP`: Ein Interface kann administrativ `UP` sein, aber kein `LOWER_UP` haben — das passiert wenn das Kabel gezogen wird. Software sagt "an", Hardware sagt "kein Signal".

> **Sonderfall `lo`:** Loopback zeigt `UNKNOWN` statt `UP` als Operstate — es hat kein physisches Kabel, daher keinen messbaren Link-Status. Traffic fließt trotzdem normal darüber. `LOWER_UP` ist für virtuelle Interfaces (lo, tunnel, veth) irrelevant.

| Weitere Felder | Bedeutung |
|----------------|-----------|
| `mtu 1500` | Maximale Paketgröße |
| `link/ether` | MAC-Adresse |

> `ip link` zeigt **keine IP-Adressen** — das ist Absicht. Layer 2 und Layer 3 sind sauber getrennt.

---

### 2. `ip addr` — IP-Adressen auf Layer 3

Hier kommen die IPs ins Spiel. Ein Interface kann mehrere IPs gleichzeitig haben — in Linux vollkommen normal.

```bash
ip addr show                          # alle IPs
ip -br -4 addr                        # nur IPv4, kompakt
ip addr show eth0                     # nur für eth0
ip addr add 192.168.99.1/24 dev eth0  # IP hinzufügen
ip addr del 192.168.99.1/24 dev eth0  # IP entfernen
```

**Beispielausgabe:**
```
inet 10.0.0.5/24 brd 10.0.0.255 scope global eth0
```

| Feld | Bedeutung |
|------|-----------|
| `inet` | IPv4 (`inet6` = IPv6) |
| `scope global` | Von außen erreichbar |
| `scope host` | Nur lokal (z.B. `127.0.0.1`) |

> Alles was du mit `ip addr add` setzt ist **temporär** — ein Reboot und es ist weg. Für persistente Konfiguration muss es in Netplan oder eine vergleichbare Konfiguration.

---

### 3. `ip route` — Routing-Tabelle

Der Kernel entscheidet anhand der Routing-Tabelle wohin ein Paket geht. `ip route` macht diese Entscheidung sichtbar.

```bash
ip route show                          # gesamte Routing-Tabelle
ip route show default                  # nur die Default Route
ip route get 8.8.8.8                   # welchen Weg nimmt ein Paket zu dieser IP?
ip route add 10.99.0.0/24 via 10.0.0.1 # statische Route setzen
ip route del 10.99.0.0/24              # wieder löschen
ip route show table local              # lokale Tabelle anzeigen
```

**`ip route get` — der mächtigste Debug-Befehl:**

```bash
ip route get 8.8.8.8
# → 8.8.8.8 via 10.0.0.1 dev eth0 src 10.0.0.5
```

Du fragst den Kernel direkt: Gateway, Interface und Source-IP — kein Raten mehr.

**Die `local`-Tabelle:**

```bash
ip route show table local
```

Hier stehen deine eigenen IPs mit `scope host`. So weiß der Kernel, dass er Pakete an sich selbst lokal behandeln soll.

---

### 4. `ip neigh` — ARP / Neighbor-Cache

"Neigh" steht für Neighbor. Das ist der ARP-Cache — die Tabelle die IP-Adressen auf MAC-Adressen mapped. Ohne das kann kein Paket im lokalen Netz ankommen.

```bash
ip neigh show                                              # gesamter ARP-Cache
ip neigh flush all                                         # Cache leeren
ip neigh add 192.168.99.99 lladdr aa:bb:cc:dd:ee:ff dev eth0  # statisch setzen
ip neigh del 192.168.99.99 dev eth0                        # löschen
```

**Zustände im ARP-Cache:**

| Zustand | Bedeutung |
|---------|-----------|
| `REACHABLE` | Frisch, gerade bestätigt |
| `STALE` | War mal gültig, noch nicht erneut geprüft |
| `FAILED` | ARP-Request ohne Antwort — Gateway down? |
| `PERMANENT` | Manuell gesetzt, wird nie gelöscht |

> `FAILED` beim Gateway bedeutet: entweder ist dein Subnetz falsch konfiguriert oder der Gateway ist wirklich nicht erreichbar.

---

### 5. `ip rule` — Policy Routing

Normalerweise hat Linux eine Routing-Tabelle. Mit `ip rule` kannst du mehrere Tabellen definieren und steuern, welche Pakete welche Tabelle nutzen — z.B. nach Source-IP oder Interface.

```bash
ip rule show
```

**Typische Ausgabe:**
```
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default
```

**Prioritäten — kleiner = höher priorisiert:**

| Priorität | Tabelle | Bedeutung |
|-----------|---------|-----------|
| `0` | `local` | Eigene IPs, Loopback — immer zuerst |
| `32766` | `main` | Normale Routing-Tabelle |
| `32767` | `default` | In der Praxis meist leer, letzter Ausweg |

**Wann relevant im RZ:**
- Multi-Homing: Server hat zwei Uplinks, Traffic soll je nach Source-IP unterschiedlich geroutet werden
- Kubernetes / MetalLB: Traffic gezielt über bestimmte Interfaces

---

### 6. `ip monitor` — Live-Monitoring

Echtzeit-Debugging ohne Polling. Alle Netzwerk-Events erscheinen sofort sobald sie passieren.

```bash
ip monitor all     # alles: Routen, IPs, ARP, Links
ip monitor route   # nur Routing-Änderungen
ip monitor neigh   # nur ARP-Änderungen ← MetalLB-Debugging
ip monitor link    # nur Link-Status (Kabel rein/raus)
```

**Typische Anwendungsfälle im RZ:**

| Szenario | Befehl |
|----------|--------|
| MetalLB-Failover beobachten | `ip monitor neigh` |
| BGP-Routen live verfolgen | `ip monitor route` |
| Interface-Flapping erkennen | `ip monitor link` |
| Gratuitous ARP sehen | `ip monitor neigh` |

---

## Schnellreferenz: Alle 6 Objects

| Object | Layer | Aufgabe | Ersetzt |
|--------|-------|---------|---------|
| `ip link` | 2 | Interfaces verwalten | `ifconfig` |
| `ip addr` | 3 | IP-Adressen verwalten | `ifconfig` |
| `ip route` | 3 | Routing-Tabelle | `route` |
| `ip neigh` | 2↔3 | ARP/Neighbor-Cache | `arp` |
| `ip rule` | — | Policy-Routing-Regeln | — |
| `ip monitor` | — | Live-Monitoring | — |
