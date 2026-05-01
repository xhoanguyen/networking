# Tag 20a — Review: Netzwerk-Debugging Systematisch

## Lernziel

Debugging im RZ ist Handwerk — kein Raten, sondern ein systematischer Layer-für-Layer-Check.
Nach diesem Tag weißt du genau wo du anfängst und wie du Schicht für Schicht ausschließt.

---

## Flashcards — erst durchgehen, dann Lab

**1. Was ist die goldene Regel beim Netzwerk-Debugging?**

Von innen nach außen — Container/Namespace → Host → Uplink. Nie umgekehrt.

**2. Ein Namespace kann die Bridge pingen aber nicht 8.8.8.8 — welche drei Checks zuerst?**

1. Default Route im Namespace: `ip netns exec <ns> ip route show` — ist `default via <bridge-ip>` da?
2. IP Forwarding auf dem Host: `cat /proc/sys/net/ipv4/ip_forward` — muss `1` sein
3. MASQUERADE-Regel: `iptables -t nat -L -v -n` — ist die Regel da und greift sie (pkts > 0)?

**3. Was zeigen die pkts/bytes Counter bei `iptables -L -v -n`?**

Wie oft eine Regel bereits getroffen wurde — ohne neuen Traffic zu erzeugen kannst du sehen ob eine Regel aktiv ist.

**4. Was ist conntrack und warum braucht NAT es?**

conntrack (Connection Tracking) verfolgt den Zustand jeder Verbindung: `NEW`, `ESTABLISHED`, `RELATED`, `INVALID`.
NAT braucht conntrack damit Antwortpakete automatisch zurückübersetzt werden — ohne conntrack käme das Antwortpaket von 8.8.8.8 an, der Host würde es nicht zuordnen können und es verwerfen.

**5. Wie siehst du aktive NAT-Übersetzungen?**

```bash
sudo conntrack -L
```

**6. Wann brauche ich IP Forwarding — wann nicht?**

- **Nicht nötig:** Ping zwischen zwei Namespaces im gleichen Subnetz an derselben Bridge — läuft auf L2
- **Nötig:** Sobald Traffic den Host als Router nutzt — Namespace → Internet, oder Namespace → anderes Netz

---

## Theorie

### Der systematische Debugging-Pfad

```
Pod/Namespace kann nicht ins Internet:

1. Im Namespace
   ip netns exec <ns> ip route show
   → Default Route via Gateway da?
   ip netns exec <ns> ip link show
   → Interface UP?

2. Auf dem Host
   cat /proc/sys/net/ipv4/ip_forward
   → Muss 1 sein

3. iptables
   sudo iptables -t nat -L -v -n
   → MASQUERADE/SNAT Regel da?
   → pkts/bytes > 0 = Regel greift

4. Uplink
   ping 8.8.8.8 vom Host selbst
   → Kann der Host ins Internet? (Upstream-Problem ausschließen)
```

### conntrack verstehen

conntrack trackt jede Verbindung als Zustandsmaschine:

| Zustand | Bedeutung |
|---------|-----------|
| NEW | Erstes Paket einer neuen Verbindung |
| ESTABLISHED | Verbindung läuft, Antwortpakete gesehen |
| RELATED | Zugehöriger Traffic (z.B. ICMP-Fehler zu einer TCP-Session) |
| INVALID | Paket passt zu keiner bekannten Verbindung |

Bei NAT: conntrack speichert die Übersetzung (Original-IP:Port → übersetzte IP:Port). Kommt das Antwortpaket zurück, schlägt der Kernel in der conntrack-Tabelle nach und übersetzt zurück — automatisch, ohne extra Regel.

**Im RZ relevant:** Wenn conntrack-Tabelle voll läuft (High-Traffic-Systeme), werden neue Verbindungen verworfen. `conntrack -L | wc -l` zeigt die aktuelle Größe.

### IP Forwarding — wann genau?

```
ns-web ──── br-internal ──── ns-db
           (gleicher L2)
```
Kein IP Forwarding nötig — Bridge leitet auf L2 weiter, Kernel-IP-Stack wird nicht involviert.

```
ns-web ──── br-internal ──── Host ──── enp0s1 ──── Internet
           (L3-Routing)
```
IP Forwarding nötig — Paket kommt auf br-internal an, muss zu enp0s1 weitergeleitet werden. Ohne `ip_forward=1` wirft der Kernel es still weg.

---

## Lab

### Vorbereitung

Baue schnell ein einfaches Setup auf:

```bash
sudo ip netns add ns-a
sudo ip netns add ns-b
sudo ip link add br0 type bridge
sudo ip link add veth-a type veth peer name veth-a-br
sudo ip link add veth-b type veth peer name veth-b-br
sudo ip link set veth-a-br master br0
sudo ip link set veth-b-br master br0
sudo ip link set br0 up
sudo ip link set veth-a-br up
sudo ip link set veth-b-br up
sudo ip link set veth-a netns ns-a
sudo ip link set veth-b netns ns-b
sudo ip netns exec ns-a ip link set veth-a up
sudo ip netns exec ns-b ip link set veth-b up
sudo ip netns exec ns-a ip addr add 10.9.0.10/24 dev veth-a
sudo ip netns exec ns-b ip addr add 10.9.0.20/24 dev veth-b
sudo ip addr add 10.9.0.1/24 dev br0
```

### Aufgabe 1 — Ping zwischen Namespaces

Ping von ns-a nach ns-b. Funktioniert es? Braucht es IP Forwarding?

Erkläre warum.

### Aufgabe 2 — Internet-Konnektivität debuggen

Versuche von ns-a `8.8.8.8` zu pingen — es wird scheitern.

Gehe den systematischen Debugging-Pfad durch:
1. Default Route prüfen
2. IP Forwarding prüfen
3. MASQUERADE prüfen

Behebe jeden Fehler einzeln und erkläre was du siehst.

### Aufgabe 3 — conntrack beobachten

Nachdem Internet-Konnektivität funktioniert:

```bash
sudo conntrack -L
```

Führe einen Ping durch und beobachte conntrack live:

```bash
sudo conntrack -E
```

Was siehst du? Erkläre die Einträge.

### Aufgabe 4 — iptables Counter lesen

```bash
sudo iptables -t nat -L -v -n
```

Führe einen Ping durch. Was ändern sich die Werte? Was bedeutet das?

### Aufräumen

```bash
sudo ip netns delete ns-a
sudo ip netns delete ns-b
sudo ip link delete br0
sudo iptables -t nat -F
sudo sysctl -w net.ipv4.ip_forward=0
```

---

## RZ Profi-Tipp

Im Produktions-RZ läuft auf jedem Node ein Monitoring-Agent der conntrack-Größe überwacht. Wenn `nf_conntrack_count` sich `nf_conntrack_max` nähert, droppen neue Verbindungen ohne Fehlermeldung — das ist einer der gemeinsten Silent-Failures in Kubernetes-Clustern. `cat /proc/sys/net/netfilter/nf_conntrack_count` und `nf_conntrack_max` im Auge behalten.
