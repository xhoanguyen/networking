# Tag 19 — SOLUTION: Container-Netzwerk komplett

## Ziel

Drei isolierte Netzwerk-Kontexte (`ns1`, `ns2`, `ns3`) — verbunden über einen virtuellen L2-Switch im Kernel (`br0`) — mit Internet-Zugang via NAT.

```
ns1 (10.0.0.2) ─┐
ns2 (10.0.0.3) ─┤── br0 (10.0.0.1) ── enp0s1 ── MASQUERADE ── Internet
ns3 (10.0.0.4) ─┘
```

---

## Schritt 1 — Bestandsaufnahme

Vor dem Bauen immer prüfen was noch existiert:

```bash
ip netns list                    # Namespaces vorhanden?
ip link show type bridge         # Bridge vorhanden?
ip addr show br0                 # Bridge hat IP?
sysctl net.ipv4.ip_forward       # IP Forwarding aktiv?
sudo iptables -t nat -L POSTROUTING -v -n   # MASQUERADE gesetzt?
```

---

## Schritt 2 — Namespaces erstellen

```bash
sudo ip netns add ns1
sudo ip netns add ns2
sudo ip netns add ns3

# Verifizieren
ip netns list
```

---

## Schritt 3 — Bridge aufbauen

```bash
sudo ip link add name br0 type bridge
sudo ip addr add 10.0.0.1/24 dev br0
sudo ip link set br0 up

# Verifizieren
ip addr show br0
```

`10.0.0.1` ist das Gateway für alle Namespaces — konventionell die `.1` im Subnet.

---

## Schritt 4 — veth pairs erstellen und an Bridge enslaven

```bash
# veth pairs erstellen
sudo ip link add veth-ns1 type veth peer name veth-ns1-br
sudo ip link add veth-ns2 type veth peer name veth-ns2-br
sudo ip link add veth-ns3 type veth peer name veth-ns3-br

# Bridge-Enden enslaven (Port attachment)
sudo ip link set veth-ns1-br master br0
sudo ip link set veth-ns2-br master br0
sudo ip link set veth-ns3-br master br0

# Bridge-Enden UP
sudo ip link set veth-ns1-br up
sudo ip link set veth-ns2-br up
sudo ip link set veth-ns3-br up

# Verifizieren
bridge link show
```

---

## Schritt 5 — Namespace-Enden verschieben und konfigurieren

```bash
# Enden in Namespaces verschieben
sudo ip link set veth-ns1 netns ns1
sudo ip link set veth-ns2 netns ns2
sudo ip link set veth-ns3 netns ns3

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

# Verifizieren
sudo ip netns exec ns1 ip route show
sudo ip netns exec ns2 ip route show
sudo ip netns exec ns3 ip route show
```

Erwartete Ausgabe pro Namespace:
```
default via 10.0.0.1 dev veth-nsX
10.0.0.0/24 dev veth-nsX proto kernel scope link src 10.0.0.X
```

---

## Schritt 6 — L2-Konnektivität testen

```bash
sudo ip netns exec ns1 ping -c 3 10.0.0.3   # ns1 → ns2
sudo ip netns exec ns2 ping -c 3 10.0.0.4   # ns2 → ns3
```

Was auf L2 passiert:
1. ns1 schaut Routing-Tabelle: `10.0.0.0/24` direkt erreichbar
2. MAC von Ziel unbekannt → ARP-Request (Broadcast)
3. Bridge flutet ARP an alle Ports (Unknown Unicast Flooding)
4. Ziel-Namespace antwortet mit seiner MAC
5. Bridge lernt: MAC ist hinter welchem Port
6. Nächster Frame geht direkt — kein Flooding mehr
7. Kein Routing, kein IP-Stack des Hosts involviert

---

## Schritt 7 — IP Forwarding aktivieren

```bash
sudo sysctl -w net.ipv4.ip_forward=1

# Verifizieren
sysctl net.ipv4.ip_forward   # muss 1 sein
```

Wichtig: IP Forwarding auf dem **Host** prüfen — nicht in den Namespaces. Die Namespaces routen nicht, der Host tut es.

---

## Schritt 8 — MASQUERADE konfigurieren

```bash
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s1 -j MASQUERADE

# Verifizieren
sudo iptables -t nat -L POSTROUTING -v -n
```

---

## Schritt 9 — Internet-Zugang testen

```bash
sudo ip netns exec ns1 ping -c 2 8.8.8.8
sudo ip netns exec ns2 ping -c 2 8.8.8.8
sudo ip netns exec ns3 ping -c 2 8.8.8.8
```

Alle drei müssen 0% packet loss haben.

---

## Vollständige Verifikation

```bash
# Bridge-Ports und State
bridge link show

# MAC-Adress-Tabelle
bridge fdb show br br0

# NAT-Regeln mit Countern
sudo iptables -t nat -L -v -n

# Aktive NAT-Verbindungen (während Ping läuft)
sudo ip netns exec ns1 ping 8.8.8.8 &
sleep 1 && sudo /usr/sbin/conntrack -L | grep 8.8.8.8
kill %1
```

conntrack zeigt die Übersetzung live:
```
src=10.0.0.2 dst=8.8.8.8 ... src=8.8.8.8 dst=192.168.2.2
```
Hinweg: private IP → Internet. Rückweg: Host-IP → conntrack übersetzt zurück auf `10.0.0.2`.

---

## Debugging-Reihenfolge wenn Internet nicht geht

```
1. Default Route im Namespace?       sudo ip netns exec nsX ip route show
2. IP Forwarding aktiv?              sysctl net.ipv4.ip_forward
3. MASQUERADE greift?                sudo iptables -t nat -L -v -n  (pkts > 0?)
4. Bridge-Ports UP?                  bridge link show
5. Paket kommt bei Bridge an?        sudo tcpdump -i br0
```

---

## Aufräumen

```bash
sudo ip netns delete ns1
sudo ip netns delete ns2
sudo ip netns delete ns3
sudo ip link delete br0          # löscht automatisch alle veth-br Enden
sudo iptables -t nat -F          # alle NAT-Regeln löschen
sudo sysctl -w net.ipv4.ip_forward=0

# Verifizieren
ip netns list                    # leer
ip link show type bridge         # leer
sudo iptables -t nat -L          # leer
```

---

## RZ Profi-Tipps

**Bestandsaufnahme zuerst** — vor dem Bauen immer prüfen was noch steht. `ip netns list`, `ip link show type bridge`, `sysctl net.ipv4.ip_forward`. Spart Zeit und verhindert Doppel-Konfigurationen.

**pkts-Counter als Debugging-Tool** — `iptables -t nat -L -v -n` zeigt ob eine Regel überhaupt greift. 0 Pakete bei laufendem Traffic = Regel greift nicht (falsche Chain, falsche Tabelle, falsche Reihenfolge).

**DNAT von außen testen** — DNAT in `PREROUTING` greift nicht wenn du vom Host selbst auf die eigene IP curlst. Immer von einem externen Client testen. Für lokalen Traffic zusätzlich `OUTPUT` Chain:
```bash
sudo iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:80
```

**IP Forwarding ist der häufigste vergessene Schritt** — temporär: `sysctl -w net.ipv4.ip_forward=1`. Dauerhaft: `/etc/sysctl.d/99-forwarding.conf` mit `net.ipv4.ip_forward=1`.

**Das ist exakt was Kubernetes macht** — jeder Pod bekommt einen eigenen Netzwerk-Kontext, ein veth pair verbindet ihn mit der Node-Bridge (`cni0`), MASQUERADE kümmert sich um ausgehenden Traffic. Cilium ersetzt iptables durch eBPF — aber der Mechanismus ist identisch.
