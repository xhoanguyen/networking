# Tag 22 — Bridge Deep Dive (FDB, MAC-Learning, Aging, Port States)

## Lernziel

Die Bridge ist das Herzstück von Container-Networking. Nach diesem Tag verstehst du
was intern passiert wenn ein Paket die Bridge durchläuft — und warum die FDB so
einfach wie elegant ist.

---

## Flashcards — erst durchgehen, dann Lab

**1. Was ist die FDB (Forwarding Database)?**

Die MAC-Adress-Tabelle der Bridge. Sie speichert: welche MAC-Adresse hinter welchem Port hängt.
Der Key ist die MAC — ein Port kann dabei zu mehreren MACs gemappt sein (z.B. Switch hinter dem Port).

```bash
bridge fdb show br br0
```

**2. Wie lernt eine Bridge MAC-Adressen?**

Passiv durch **Source Learning** — sie schaut bei jedem eingehenden Frame auf die Source-MAC
und merkt sich: "Diese MAC kam von diesem Port." Kein aktives Protokoll, kein ARP — einfach beobachten.

**3. Was ist Unknown Unicast Flooding?**

Wenn die **Ziel-MAC** in der FDB unbekannt ist, sendet die Bridge den Frame an alle Ports
außer dem Eingangsport. Tritt auf bei: neuen Verbindungen (vor erstem Ping), nach FDB-Timeout (~300s),
nach Bridge-Neustart.

**4. Was passiert wenn ein FDB-Eintrag veraltet ist und das Gerät an einem neuen Port hängt?**

Das erste Frame des Geräts vom neuen Port überschreibt den alten Eintrag sofort — kein Flooding nötig,
weil Source Learning bei jedem eingehenden Frame passiert.

**5. Was ist der Aging Timer?**

FDB-Einträge werden nach ~300 Sekunden ohne Traffic gelöscht. Das sorgt dafür dass
Topologie-Änderungen (Gerät wechselt Port, VM migriert) automatisch auffangen werden.

**6. Kann ein Bridge-Port mehrere MACs haben?**

Ja — wenn ein weiterer Switch hinter dem Port hängt, lernt die Bridge alle MACs der dahinter
liegenden Geräte auf demselben Port.

**7. Was sind die möglichen Bridge-Port States?**

| State | Bedeutung |
|-------|-----------|
| `disabled` | Port ist inaktiv — kein Traffic |
| `listening` | STP: Port hört zu, lernt noch keine MACs |
| `learning` | Port lernt MACs, leitet aber noch keinen Traffic weiter |
| `forwarding` | Normal — Port leitet Traffic weiter |
| `blocking` | STP: Port blockiert aktiv um Loops zu verhindern |

**8. Wie siehst du Bridge-Ports mit State?**

```bash
bridge link show
# oder
ip link show master br0
```

- `bridge link show` — zeigt Bridge-Ports mit STP-State, Master, Flags
- `ip link show master br0` — zeigt alle Interfaces die br0 als Master haben, ohne STP-Details

---

## Theorie

### Der Weg eines Frames durch die Bridge

```
ns-a sendet Ping an ns-b (10.9.0.20):

1. ARP: "Wer hat 10.9.0.20?"
   → Frame kommt auf veth-a-br an
   → Bridge lernt: MAC von ns-a = hinter Port veth-a-br
   → Ziel-MAC unbekannt → Flooding an alle Ports

2. ns-b antwortet ARP
   → Frame kommt auf veth-b-br an
   → Bridge lernt: MAC von ns-b = hinter Port veth-b-br
   → FDB jetzt vollständig

3. Ping-Paket
   → Bridge schlägt Ziel-MAC in FDB nach
   → Direktweiterleitung an veth-b-br, kein Flooding mehr
```

### FDB-Einträge verstehen

```bash
bridge fdb show br br0
```

Typische Ausgabe:
```
26:5f:f0:f2:66:aa dev veth-a-br master br0    ← dynamisch gelernt (ns-a)
a2:fe:36:38:f4:0b dev veth-b-br master br0    ← dynamisch gelernt (ns-b)
00:00:00:00:00:00 dev veth-a-br self permanent ← Broadcast-Eintrag
33:33:00:00:00:01 dev veth-a-br self permanent ← IPv6 Multicast
```

- `master br0` = Eintrag gehört zur Bridge
- `self` = Eintrag gehört dem Interface selbst
- `permanent` = statisch, läuft nicht ab
- Ohne `permanent` = dynamisch gelernt, läuft nach ~300s ab

### Warum `state disabled`?

Häufigste Ursachen im Lab:

1. **Interface DOWN** — das Interface selbst oder das Gegenstück ist nicht `UP`
2. **STP blockiert** — Bridge hat STP aktiviert, Port wird als redundant eingestuft
3. **NO-CARRIER** — das veth-Gegenstück ist DOWN (typisch nach `netns`-Verschiebung ohne `ip link set up`)

Linux-Bridges haben STP standardmäßig **deaktiviert** — im Lab also meist Ursache 1 oder 3.

---

## Lab

### Setup

```bash
# Bridge erstellen
sudo ip link add br0 type bridge
sudo ip link set br0 up

# Namespace A
sudo ip netns add ns-a
sudo ip link add veth-a type veth peer name veth-a-br
sudo ip link set veth-a-br master br0
sudo ip link set veth-a-br up
sudo ip link set veth-a netns ns-a
sudo ip netns exec ns-a ip link set veth-a up
sudo ip netns exec ns-a ip addr add 10.9.0.10/24 dev veth-a

# Namespace B
sudo ip netns add ns-b
sudo ip link add veth-b type veth peer name veth-b-br
sudo ip link set veth-b-br master br0
sudo ip link set veth-b-br up
sudo ip link set veth-b netns ns-b
sudo ip netns exec ns-b ip link set veth-b up
sudo ip netns exec ns-b ip addr add 10.9.0.20/24 dev veth-b

# Namespace C
sudo ip netns add ns-c
sudo ip link add veth-c type veth peer name veth-c-br
sudo ip link set veth-c-br master br0
sudo ip link set veth-c-br up
sudo ip link set veth-c netns ns-c
sudo ip netns exec ns-c ip link set veth-c up
sudo ip netns exec ns-c ip addr add 10.9.0.30/24 dev veth-c
```

---

### Aufgabe 1 — FDB vor dem ersten Ping

Schau dir die FDB an bevor du irgendetwas pingst:

```bash
bridge fdb show br br0
```

Was siehst du? Erkläre jeden Eintrag — warum sind schon Einträge da obwohl noch kein Traffic war?

---

### Aufgabe 2 — FDB beim ersten Ping beobachten

Ping von ns-a nach ns-b:

```bash
sudo ip netns exec ns-a ping -c1 10.9.0.20
```

Direkt danach:

```bash
bridge fdb show br br0
```

Was hat sich geändert? Wie viele neue Einträge siehst du — und warum genau diese?

---

### Aufgabe 3 — Aging Timer verkürzen und beobachten

Verkürze den Aging Timer auf 10 Sekunden:

```bash
sudo ip link set br0 type bridge ageing_time 1000
```

*(Einheit: Centisekunden — 1000 = 10s)*

Ping nochmal, FDB prüfen, dann 15 Sekunden warten:

```bash
bridge fdb show br br0
sleep 15
bridge fdb show br br0
```

Was ist passiert? Was passiert beim nächsten Ping — und was siehst du mit tcpdump?

```bash
sudo tcpdump -i br0 -n arp &
sudo ip netns exec ns-a ping -c1 10.9.0.20
```

---

### Aufgabe 4 — Port State provozieren

Bringe das bridge-seitige veth-Interface von ns-b DOWN:

```bash
sudo ip link set veth-b-br down
```

Prüfe den Port State:

```bash
bridge link show
```

Was siehst du? Versuche von ns-a nach ns-b zu pingen — was passiert?
Bringe es wieder hoch und prüfe erneut.

---

### Aufgabe 5 — Switch hinter einem Port (mehrere MACs pro Port)

Hier simulieren wir einen zweiten Switch hinter `veth-c-br` — zwei Namespaces teilen sich einen Bridge-Port.

```bash
# Zweite Bridge als "Switch"
sudo ip link add br1 type bridge
sudo ip link set br1 up

# veth-c-br Seite in br1 hängen (simuliert Switch-Uplink)
# Namespace D hinter br1
sudo ip netns add ns-d
sudo ip link add veth-d type veth peer name veth-d-br
sudo ip link set veth-d-br master br1
sudo ip link set veth-d-br up
sudo ip link set veth-d netns ns-d
sudo ip netns exec ns-d ip link set veth-d up
sudo ip netns exec ns-d ip addr add 10.9.0.40/24 dev veth-d

# br1 mit br0 verbinden über ein veth-Paar
sudo ip link add uplink type veth peer name uplink-br
sudo ip link set uplink master br1
sudo ip link set uplink up
sudo ip link set uplink-br master br0
sudo ip link set uplink-br up
```

Ping von ns-a nach ns-d, dann FDB prüfen:

```bash
sudo ip netns exec ns-a ping -c1 10.9.0.40
bridge fdb show br br0
```

Auf welchem Port taucht die MAC von ns-d auf? Was bedeutet das für die FDB-Regel "ein Port, eine MAC"?

---

### Aufräumen

```bash
sudo ip netns delete ns-a
sudo ip netns delete ns-b
sudo ip netns delete ns-c
sudo ip netns delete ns-d
sudo ip link delete br0
sudo ip link delete br1
```

---

## RZ Profi-Tipp

In Kubernetes-Umgebungen (RKE2 + Cilium) siehst du oft viele veth-Interfaces mit der gleichen Bridge als Master — jeder Pod bekommt ein eigenes veth-Paar. Die Bridge-FDB kann schnell hunderte Einträge haben. `bridge fdb show br cni0 | wc -l` gibt dir sofort einen Überblick über die Größe der L2-Tabelle. Wenn Pods sich plötzlich nicht mehr erreichen, ist ein leerer FDB-Eintrag (fehlgeschlagenes MAC-Learning) oft der erste Verdächtige.
