# Tag 13 — Lösungen

> Interface in der VM: `enp0s1` (nicht `eth0` wie in den Aufgaben)

---

## Block A — Interfaces lesen (ip link)

**A1 ★**

```bash
ip -br -c link show
```

```
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
enp0s1           UP             52:54:00:7e:d5:31 <BROADCAST,MULTICAST,UP,LOWER_UP>
```

Zwei Interfaces: `lo` (UNKNOWN — kein physischer Link-Status messbar, kein Fehler) und `enp0s1` (UP).

---

**A2 ★**

```bash
ip -s -h link show enp0s1
```

Keine Errors oder Drops. RX deutlich größer als TX wegen `apt update` beim Setup.

> Flags müssen getrennt angegeben werden: `-s -h` funktioniert, `-sh` nicht.

---

**A3 ★★**

```bash
ip link show enp0s1 | grep ether
```

```
link/ether 52:54:00:7e:d5:31 brd ff:ff:ff:ff:ff:ff
```

MAC: `52:54:00:7e:d5:31` — Prefix `52:54:00` ist der QEMU/KVM OUI → virtuelle Maschine erkennbar.

---

**A4 ★★**

```bash
sudo at now + 1 minute
> sudo ip link set enp0s1 up
> <Ctrl+D>

sudo ip link set enp0s1 down
```

Interface down → Multipass-Verbindung verloren. `at`-Job muss mit `sudo` laufen, sonst schlägt `ip link set up` mit "Operation not permitted" fehl. VM-Neustart als Fallback: `multipass stop rz-node --force && multipass start rz-node`.

---

**A5 — Promiscuous Mode**

```bash
sudo ip link set enp0s1 promisc on
ip link show enp0s1
```

Flag `PROMISC` erscheint in `<BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP>`. Interface nimmt alle Pakete im Segment an, nicht nur die eigenen. Wird für Packet Sniffing gebraucht (tcpdump, Wireshark, IDS).

```bash
sudo ip link set enp0s1 promisc off
```

---

**A6 — Statistiken mit `-s -s`**

```bash
ip -s -s link show enp0s1
```

```
RX:  bytes packets errors dropped  missed   mcast
     71874     550      0       0       0       0
RX errors:  length    crc   frame    fifo overrun
                 0      0       0       0       0
TX:  bytes packets errors dropped carrier collsns
     87198     412      0       0       0       0
TX errors: aborted   fifo  window heartbt transns
                 0      0       0       0       2
```

`-s` zeigt RX/TX Zähler. `-s -s` zeigt zusätzlich aufgeschlüsselte Fehler-Kategorien. `transns: 2` = transmit timeouts, in einer VM normal. Zähler leben nur im RAM — Reset nach Neustart.

---

## Block B — IP-Adressen verwalten (ip addr)

**B1 ★**

```bash
ip -4 -br addr show
```

```
lo               UNKNOWN        127.0.0.1/8
enp0s1           UP             192.168.2.2/24 metric 100
```

---

**B2 ★★**

```bash
sudo ip addr add 192.168.99.1/24 dev enp0s1
ip addr show enp0s1
sudo ip addr del 192.168.99.1/24 dev enp0s1
```

Ja, Linux erlaubt mehrere IPs pro Interface. Use Cases: HA mit Virtual IPs (Keepalived), MetalLB im RZ.

Unterschiede zwischen DHCP-IP und manueller IP:
- `dynamic` + `valid_lft 2360sec` → kam von DHCP, Lease läuft ab
- keine `dynamic` + `valid_lft forever` → manuell gesetzt, kein Ablaufdatum
- DHCP-IP hat `brd` (Broadcast) und `metric`, manuelle nicht automatisch

---

**B3 ★★**

```bash
ip -j addr show enp0s1 | jq '.[0].addr_info[] | select(.family=="inet") | .local'
```

```
"192.168.2.2"
```

Das Wichtige: `ip -j` gibt JSON aus und kann damit gescriptet werden. Die `jq`-Syntax selbst ist Nachschlagewerk.

---

**B4 ★★★**

```bash
ip addr show | grep 127.0.0.1
```

```
inet 127.0.0.1/8 scope host lo
```

Liegt auf `lo`.

---

## Block C — Routing (ip route)

_noch offen_

---

## Block D — ARP / Neighbor-Cache (ip neigh)

_noch offen_

---

## Block E — Monitoring und Debugging (ip monitor)

_noch offen_
