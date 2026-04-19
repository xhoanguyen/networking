# Tag 18 — SOLUTION: NAT

## Aufgabe 1 — IP Forwarding aktivieren

Prüfen:
```bash
cat /proc/sys/net/ipv4/ip_forward
```

Temporär aktivieren (bis Reboot):
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

Dauerhaft (in Datei):
```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Was ohne IP Forwarding passiert:** Der Kernel empfängt das Paket von ns1 — sieht dass es nicht für ihn bestimmt ist — und verwirft es still. iptables FORWARD wird nie erreicht.

## Aufgabe 2 — Default Route in Namespaces

Routing-Tabelle prüfen:
```bash
sudo ip netns exec ns1 ip route show
# 10.0.0.0/24 dev veth-ns1 proto kernel scope link src 10.0.0.2
```

Default Route fehlt — Pakete an 8.8.8.8 haben kein Matching Route:
```bash
sudo ip netns exec ns1 ip route add default via 10.0.0.1
sudo ip netns exec ns2 ip route add default via 10.0.0.1
sudo ip netns exec ns3 ip route add default via 10.0.0.1
```

**Danach:**
```
10.0.0.0/24 dev veth-ns1 proto kernel scope link src 10.0.0.2
default via 10.0.0.1 dev veth-ns1
```

## Aufgabe 3 — MASQUERADE konfigurieren

```bash
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s1 -j MASQUERADE
```

**Erklärung:**
- `-t nat` — nat-Tabelle
- `-A POSTROUTING` — nach der Routing-Entscheidung, vor dem Raussenden
- `-s 10.0.0.0/24` — nur für Pakete aus unserem Namespace-Subnetz
- `-o enp0s1` — über das externe Interface (Interface-Name auf rz-node)
- `-j MASQUERADE` — ersetze Absender-IP mit IP von enp0s1

## Aufgabe 4 — Ping testen und Debugging

```bash
sudo ip netns exec ns1 ping -c 3 8.8.8.8
```

**Debugging-Schritte wenn es nicht funktioniert:**

1. IP Forwarding prüfen:
```bash
cat /proc/sys/net/ipv4/ip_forward
```

2. FORWARD Chain prüfen:
```bash
sudo iptables -L FORWARD -v -n
```

3. Kommt Paket bei der Bridge an?
```bash
sudo tcpdump -i br0 -n icmp
```

4. Leitet der Host weiter?
```bash
sudo tcpdump -i enp0s1 -n icmp
```

5. NAT-Regel prüfen:
```bash
sudo iptables -t nat -L POSTROUTING -v -n
```

## Aufgabe 5 — NAT-Tabelle beobachten

```bash
sudo iptables -t nat -L -v -n
```

`pkts` und `bytes` zeigen wie viele Pakete die Regel getroffen haben — wichtiger Counter für Debugging: wenn `pkts = 0` nach einem Ping, greift die Regel nicht.

```bash
sudo conntrack -L | grep 8.8.8.8
```

Du siehst die Übersetzung in beide Richtungen:
```
icmp ... src=10.0.0.2 dst=8.8.8.8 ... src=8.8.8.8 dst=<host-ip> ...
```

## Bonus — DNAT Port Forwarding

```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:80
```

Und damit der Host selbst auch weiterleitet (für lokale Verbindungen):
```bash
sudo iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:80
```

Test:
```bash
curl http://localhost:8080
```

## Mini-Quiz Antworten

1. **Welche Felder verändert MASQUERADE?** Source IP (von `10.0.0.2` auf Host-IP) und Source Port (um Verbindungen auseinanderhalten zu können). Destination IP und Payload bleiben unverändert.

2. **Wie weiß der Host dass die Antwort für ns1 ist?** conntrack hat beim Hinweg die Übersetzung gespeichert: `(host-ip, src-port) → (10.0.0.2, original-port)`. Das Antwortpaket trifft diese conntrack-Entry und wird automatisch zurückübersetzt (DNAT in PREROUTING).

3. **Warum brauchen Kubernetes-Pods NAT?** Pod-IPs sind Cluster-intern (z.B. `10.244.x.x`) — das Internet kennt sie nicht. Der Node macht MASQUERADE bevor Pakete das Cluster verlassen. Genau dasselbe wie heute — nur automatisiert durch kube-proxy / CNI.
