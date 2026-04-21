# Tag 16 — SOLUTION: Linux Bridge

## Aufgabe 1 — Bridge erstellen

```bash
sudo ip link add name br0 type bridge
sudo ip link set br0 up
sudo ip addr add 10.0.0.1/24 dev br0
```

## Aufgabe 2 — Namespaces und veth pairs erstellen

```bash
# Namespaces
sudo ip netns add ns1
sudo ip netns add ns2
sudo ip netns add ns3

# veth pairs erstellen (ein Ende pro Namespace, ein Ende für die Bridge)
sudo ip link add veth-ns1 type veth peer name veth-ns1-br
sudo ip link add veth-ns2 type veth peer name veth-ns2-br
sudo ip link add veth-ns3 type veth peer name veth-ns3-br

# Bridge-Enden an die Bridge hängen (als Ports)
sudo ip link set veth-ns1-br master br0
sudo ip link set veth-ns2-br master br0
sudo ip link set veth-ns3-br master br0

# Bridge-Enden hochbringen
sudo ip link set veth-ns1-br up
sudo ip link set veth-ns2-br up
sudo ip link set veth-ns3-br up

# Namespace-Enden in die Namespaces verschieben
sudo ip link set veth-ns1 netns ns1
sudo ip link set veth-ns2 netns ns2
sudo ip link set veth-ns3 netns ns3
```

## Aufgabe 3 — IPs vergeben und aktivieren

```bash
# ns1
sudo ip netns exec ns1 ip link set lo up
sudo ip netns exec ns1 ip link set veth-ns1 up
sudo ip netns exec ns1 ip addr add 10.0.0.2/24 dev veth-ns1
sudo ip netns exec ns1 ip route add default via 10.0.0.1

# ns2
sudo ip netns exec ns2 ip link set lo up
sudo ip netns exec ns2 ip link set veth-ns2 up
sudo ip netns exec ns2 ip addr add 10.0.0.3/24 dev veth-ns2
sudo ip netns exec ns2 ip route add default via 10.0.0.1

# ns3
sudo ip netns exec ns3 ip link set lo up
sudo ip netns exec ns3 ip link set veth-ns3 up
sudo ip netns exec ns3 ip addr add 10.0.0.4/24 dev veth-ns3
sudo ip netns exec ns3 ip route add default via 10.0.0.1
```

**Hinweis:** Die veth-Enden an der Bridge (`veth-ns1-br`, etc.) brauchen keine IP — sie sind Layer-2-Ports, wie Kabel die im Switch stecken.

## Aufgabe 4 — Ping testen

```bash
# ns1 → ns2
sudo ip netns exec ns1 ping -c 3 10.0.0.3

# ns1 → ns3
sudo ip netns exec ns1 ping -c 3 10.0.0.4

# ns2 → ns3
sudo ip netns exec ns2 ping -c 3 10.0.0.4

# Alle → Bridge (Gateway)
sudo ip netns exec ns1 ping -c 3 10.0.0.1
sudo ip netns exec ns2 ping -c 3 10.0.0.1
sudo ip netns exec ns3 ping -c 3 10.0.0.1

# Routing-Tabelle prüfen
sudo ip netns exec ns1 ip route show
```

**Erwartete Route in jedem Namespace:**
```
10.0.0.0/24 dev veth-ns1 proto kernel scope link src 10.0.0.2
default via 10.0.0.1 dev veth-ns1
```

## Aufgabe 5 — MAC-Learning beobachten

```bash
# Vor dem Ping
bridge fdb show br br0

# Ping ausführen
sudo ip netns exec ns1 ping -c 1 10.0.0.3

# Nach dem Ping
bridge fdb show br br0
```

Nach dem Ping tauchen neue Einträge auf — die Bridge hat gelernt welche MAC-Adresse hinter welchem Port liegt.

## Aufräumen

```bash
sudo ip netns delete ns1
sudo ip netns delete ns2
sudo ip netns delete ns3

# Bridge bleibt! Sie ist nicht an einen Namespace gebunden
sudo ip link delete br0
```

## Mini-Quiz Antworten

1. **Fünf Container:** 5 veth pairs, 1 Bridge — jeder Container bekommt ein veth pair, alle Bridge-Enden hängen am selben Switch.

2. **Kein Internet:** Wahrscheinlich fehlt entweder die Default Route im Namespace (`ip route add default via <bridge-ip>`) oder IP-Forwarding auf dem Host (`sysctl net.ipv4.ip_forward=1`) oder NAT (`iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE`).

3. **`master br0` in bridge fdb:** Diese MAC-Adresse wurde auf einem Port gelernt der zur Bridge `br0` gehört — der Eintrag zeigt der Bridge wo sie Frames für diese MAC hinschicken soll.
