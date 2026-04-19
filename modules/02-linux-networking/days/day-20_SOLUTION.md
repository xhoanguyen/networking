# Tag 20 — SOLUTION: Final Exam

## Teil 1 — Theorie

### Block A — Konzepte

**1. Network Namespace vs Firewall:**
Ein Namespace isoliert durch fehlende Konnektivität — das Interface existiert schlicht nicht im anderen Kontext. Eine Firewall-Regel lässt das Interface sichtbar, blockiert aber Traffic. Namespace = strukturelle Isolation, Firewall = regelbasierte Isolation.

**2. veth pair vs Bridge:**
veth pair = virtuelles Kabel, verbindet genau zwei Endpunkte. Bridge = virtueller Switch, verbindet beliebig viele. Für 2 Namespaces: veth pair reicht. Für 3+: Bridge.

**3. MAC-Learning:**
Die Bridge merkt sich welche MAC-Adresse hinter welchem Port liegt (Forwarding Database). Ohne MAC-Learning müsste sie jeden Frame an alle Ports fluten (Unknown Unicast Flooding). Mit gelernten MACs leitet sie gezielt weiter — weniger Traffic, bessere Performance.

**4. docker0 mit IP:**
Ein Linux-Interface kann gleichzeitig auf L2 (Bridge) und L3 (IP) operieren. Die IP auf `docker0` macht den Host zum Gateway für Container — Container können darüber den Host erreichen und über ihn ins Internet routen.

**5. Unknown Unicast Flooding:**
Wenn die Ziel-MAC in der FDB unbekannt ist, sendet die Bridge den Frame an alle Ports außer dem Eingang. Tritt auf bei: neuen Verbindungen (vor ARP), nach FDB-Timeout, nach Bridge-Neustart.

### Block B — Befehle

**6. Interfaces an Bridge:**
```bash
bridge link show
# oder
ip link show master br0
```

**7. MAC-Adress-Tabelle:**
```bash
bridge fdb show br br0
```

**8. Namespace-Verschiebung verifizieren:**
```bash
sudo ip netns exec ns1 ip link show
# veth-ns1 muss dort auftauchen
```

**9. Aktive NAT-Übersetzungen:**
```bash
sudo conntrack -L
```

**10. iptables-Regel prüfen ohne Traffic:**
```bash
sudo iptables -L -v -n --line-numbers
# pkts/bytes Counter zeigen ob eine Regel je getroffen wurde
# Alternativ: iptables -t nat -L -v -n für NAT-Tabelle
```

### Block C — Debugging

**11. Namespace kann Bridge pingen aber nicht 8.8.8.8:**
1. `ip netns exec ns1 ip route show` — Default Route via Bridge da?
2. `cat /proc/sys/net/ipv4/ip_forward` — Forwarding aktiv?
3. `iptables -t nat -L -v -n` — MASQUERADE-Regel vorhanden und greift sie?

**12. `state disabled` auf Bridge-Port:**
Mögliche Ursachen: Interface ist DOWN, Spanning Tree Protocol (STP) blockiert den Port, kein Carrier-Signal (Gegenstück DOWN).

**13. NO-CARRIER auf veth:**
Das Gegenstück des veth pairs ist DOWN. Fix: `ip link set <gegenstück> up`. Bei veth pairs in Namespaces: Interface existiert, ist aber DOWN weil es gerade erst verschoben wurde.

**14. Ping ns1 → ns2 funktioniert nicht:**
- Interface im Namespace ist DOWN
- Falsche IP oder falsches Subnetz (z.B. `10.0.0.2/32` statt `/24`)
- Bridge-Port ist nicht in state `forwarding` (noch `disabled` oder `learning`)
- ARP funktioniert nicht (prüfe mit `ip netns exec ns1 ip neigh show`)

### Block D — RZ Praxis

**15. Pod kann andere Pods pingen aber nicht Internet:**
Layer-Check:
- L3 Namespace: Default Route vorhanden? (`ip route show`)
- L3 Host: IP Forwarding aktiv? (`/proc/sys/net/ipv4/ip_forward`)
- iptables: MASQUERADE-Regel greift? (`iptables -t nat -L -v -n`)
- L2: Bridge-Port in forwarding? (`bridge link show`)
- Routing auf dem Host: Kann der Host selbst ins Internet? (`ping 8.8.8.8`)

**16. MASQUERADE vs SNAT im RZ:**
MASQUERADE: ersetzt IP dynamisch mit aktueller Interface-IP — für DHCP-Interfaces. Overhead durch Interface-Lookup pro Paket. SNAT: feste Ziel-IP — kein Lookup, effizienter. Im RZ mit statischen IPs immer SNAT bevorzugen.

**17. Container bekommt 172.17.x.x:**
Docker erstellt beim Start automatisch die Bridge `docker0` (Standard: `172.17.0.1/16`). Für jeden Container: neuen Namespace erstellen, veth pair erstellen, Bridge-Ende an `docker0` enslaven, Namespace-Ende konfigurieren (IP aus dem `/16` Subnetz, Default Route via `172.17.0.1`).

**18. Gratuitous ARP:**
ARP-Announcement ohne vorherige Anfrage — ein Host verkündet seine eigene IP→MAC-Zuordnung. Wird eingesetzt bei: Failover (neue IP übernommen, alle Nachbarn müssen Cache aktualisieren), beim Hochfahren (Cache-Poisoning verhindern), MetalLB L2-Mode (verkündet Service-IP nach Node-Wechsel).

---

## Teil 2 — Lab Solution

```bash
# Namespaces
sudo ip netns add ns-web
sudo ip netns add ns-db
sudo ip netns add ns-cache

# Bridge
sudo ip link add name br-internal type bridge
sudo ip addr add 10.2.0.1/24 dev br-internal
sudo ip link set br-internal up

# veth pairs
sudo ip link add veth-web type veth peer name veth-web-br
sudo ip link add veth-db type veth peer name veth-db-br
sudo ip link add veth-cache type veth peer name veth-cache-br

# Bridge-Enden enslaven
sudo ip link set veth-web-br master br-internal
sudo ip link set veth-db-br master br-internal
sudo ip link set veth-cache-br master br-internal

# Bridge-Enden UP
sudo ip link set veth-web-br up
sudo ip link set veth-db-br up
sudo ip link set veth-cache-br up

# Namespace-Enden verschieben
sudo ip link set veth-web netns ns-web
sudo ip link set veth-db netns ns-db
sudo ip link set veth-cache netns ns-cache

# ns-web
sudo ip netns exec ns-web ip link set lo up
sudo ip netns exec ns-web ip link set veth-web up
sudo ip netns exec ns-web ip addr add 10.2.0.10/24 dev veth-web
sudo ip netns exec ns-web ip route add default via 10.2.0.1

# ns-db
sudo ip netns exec ns-db ip link set lo up
sudo ip netns exec ns-db ip link set veth-db up
sudo ip netns exec ns-db ip addr add 10.2.0.20/24 dev veth-db
sudo ip netns exec ns-db ip route add default via 10.2.0.1

# ns-cache
sudo ip netns exec ns-cache ip link set lo up
sudo ip netns exec ns-cache ip link set veth-cache up
sudo ip netns exec ns-cache ip addr add 10.2.0.30/24 dev veth-cache
sudo ip netns exec ns-cache ip route add default via 10.2.0.1

# IP Forwarding + NAT
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.2.0.0/24 -o enp0s1 -j MASQUERADE
```

### Bonus — DNAT

```bash
# HTTP-Server in ns-web
sudo ip netns exec ns-web python3 -m http.server 8000 &

# DNAT: Host-Port 8080 → ns-web:8000
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.2.0.10:8000
sudo iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 10.2.0.10:8000

# Test
curl http://localhost:8080
```

### Aufräumen

```bash
sudo ip netns delete ns-web
sudo ip netns delete ns-db
sudo ip netns delete ns-cache
sudo ip link delete br-internal
sudo iptables -t nat -F
sudo sysctl -w net.ipv4.ip_forward=0
```
