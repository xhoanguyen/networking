# Tag 19 — SOLUTION: Container-Netzwerk komplett

## Aufgabe 1 — Sauberer Start

```bash
# Namespaces prüfen
ip netns list

# Bridge prüfen
ip link show type bridge

# Aufräumen falls nötig
sudo ip netns delete ns1
sudo ip netns delete ns2
sudo ip link delete br0
sudo iptables -t nat -F
```

## Aufgabe 2 — Namespaces erstellen

```bash
sudo ip netns add ns1
sudo ip netns add ns2

# Verifizieren
ip netns list
```

## Aufgabe 3 — Bridge aufbauen

```bash
sudo ip link add name br0 type bridge
sudo ip addr add 10.1.0.1/24 dev br0
sudo ip link set br0 up

# Verifizieren
ip addr show br0
```

## Aufgabe 4 — veth pairs erstellen und verbinden

```bash
# veth pairs erstellen
sudo ip link add veth-ns1 type veth peer name veth-ns1-br
sudo ip link add veth-ns2 type veth peer name veth-ns2-br

# Bridge-Enden enslaven
sudo ip link set veth-ns1-br master br0
sudo ip link set veth-ns2-br master br0

# Alle Bridge-Enden UP
sudo ip link set veth-ns1-br up
sudo ip link set veth-ns2-br up

# Namespace-Enden UP (noch im Root-Namespace)
sudo ip link set veth-ns1 up
sudo ip link set veth-ns2 up

# Verifizieren
bridge link show
```

## Aufgabe 5 — Namespaces konfigurieren

```bash
# Namespace-Enden verschieben
sudo ip link set veth-ns1 netns ns1
sudo ip link set veth-ns2 netns ns2

# ns1
sudo ip netns exec ns1 ip link set lo up
sudo ip netns exec ns1 ip link set veth-ns1 up
sudo ip netns exec ns1 ip addr add 10.1.0.2/24 dev veth-ns1
sudo ip netns exec ns1 ip route add default via 10.1.0.1

# ns2
sudo ip netns exec ns2 ip link set lo up
sudo ip netns exec ns2 ip link set veth-ns2 up
sudo ip netns exec ns2 ip addr add 10.1.0.3/24 dev veth-ns2
sudo ip netns exec ns2 ip route add default via 10.1.0.1

# Verifizieren
sudo ip netns exec ns1 ip addr show
sudo ip netns exec ns1 ip route show
```

## Aufgabe 6 — L2 testen

```bash
sudo ip netns exec ns1 ping -c 3 10.1.0.3
```

**Was auf L2 passiert:**
1. ns1 schaut in Routing-Tabelle: `10.1.0.0/24` ist direkt erreichbar
2. ns1 kennt die MAC von `10.1.0.3` nicht — sendet ARP-Request (Broadcast)
3. Bridge flutet ARP an alle Ports
4. ns2 antwortet mit seiner MAC
5. Bridge lernt: ns2-MAC ist hinter `veth-ns2-br`
6. ns1 sendet ICMP direkt an ns2-MAC — Bridge leitet gezielt weiter
7. Kein Routing, kein IP-Stack des Hosts involviert

## Aufgabe 7 — Internet-Zugang

```bash
# IP Forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/24 -o enp0s1 -j MASQUERADE

# Test
sudo ip netns exec ns1 ping -c 3 8.8.8.8
```

**Drei Dinge beim Debugging:**
1. Default Route im Namespace vorhanden?
2. IP Forwarding aktiv?
3. MASQUERADE-Regel greift? (`iptables -t nat -L -v -n` — pkts > 0?)

## Aufgabe 8 — Verifizierung

```bash
bridge link show
# → Ports in state "forwarding", LOWER_UP

bridge fdb show br br0
# → gelernte MACs, dynamisch + permanent

sudo iptables -t nat -L -v -n
# → MASQUERADE-Regel mit pkts/bytes Counter

sudo conntrack -L
# → aktive Verbindungen mit Übersetzungen

sudo ip netns exec ns1 ip route show
# → Connected Route + Default Route via 10.1.0.1
```

## Aufräumen

```bash
sudo ip netns delete ns1
sudo ip netns delete ns2
sudo ip link delete br0        # löscht auch veth-ns1-br, veth-ns2-br
sudo iptables -t nat -F        # alle NAT-Regeln
sudo sysctl -w net.ipv4.ip_forward=0

# Verifizieren
ip netns list                  # leer
ip link show type bridge       # leer
iptables -t nat -L             # leer
```

## Mini-Quiz Antworten

1. **Was Docker automatisch macht:** Namespace erstellen (pro Container), veth pair erstellen, Bridge-Ende an `docker0` enslaven, Namespace-Ende konfigurieren (IP, Default Route), MASQUERADE ist einmalig beim Docker-Start gesetzt.

2. **Container kann nicht ins Internet — erste drei Schritte:**
   - `docker exec <container> ip route show` — Default Route da?
   - `cat /proc/sys/net/ipv4/ip_forward` — Forwarding aktiv?
   - `iptables -t nat -L -v -n | grep MASQUERADE` — Regel da und greift sie?

3. **Zwei Pods auf demselben Node:** L2 — über die Node-Bridge (z.B. `cni0`). Gleicher Mechanismus wie heute: Bridge leitet Frames direkt weiter, kein Routing nötig. Der Kernel-IP-Stack des Nodes ist nicht involviert.

4. **conntrack ESTABLISHED:** Die Verbindung ist bereits aufgebaut — Antwortpakete kommen automatisch durch ohne extra Firewall-Regel. conntrack übersetzt die Ziel-IP zurück auf die ursprüngliche private IP.
