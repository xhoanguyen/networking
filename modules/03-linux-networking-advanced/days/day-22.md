# Tag 20b — Review: Bridge Deep Dive (FDB, MAC-Learning, STP, Port States)

## Lernziel

Die Bridge ist das Herzstück von Container-Networking. Nach diesem Tag verstehst du
was intern passiert wenn ein Paket die Bridge durchläuft — und warum Ports manchmal
auf `disabled` hängen.

---

## Flashcards — erst durchgehen, dann Lab

**1. Was ist die FDB (Forwarding Database)?**

Die MAC-Adress-Tabelle der Bridge. Sie speichert: welche MAC-Adresse hinter welchem Port hängt.
Befehl: `bridge fdb show br <bridge-name>`

**2. Wie lernt eine Bridge MAC-Adressen?**

Passiv — sie schaut sich eingehende Frames an und merkt sich: "Diese MAC-Adresse kam von diesem Port."
Das nennt man MAC-Learning. Keine aktive Anfrage, kein ARP — einfach beobachten.

**3. Was ist Unknown Unicast Flooding?**

Wenn die Ziel-MAC in der FDB nicht bekannt ist, sendet die Bridge den Frame an **alle Ports** außer dem Eingangsport.
Tritt auf bei: neuen Verbindungen (vor erstem ARP), nach FDB-Timeout (~300s), nach Bridge-Neustart.

**4. Was sind die möglichen Bridge-Port States?**

| State | Bedeutung |
|-------|-----------|
| `disabled` | Port ist inaktiv — kein Traffic |
| `listening` | STP: Port hört zu, lernt noch keine MACs |
| `learning` | Port lernt MACs, leitet aber noch keinen Traffic weiter |
| `forwarding` | Normal — Port leitet Traffic weiter |
| `blocking` | STP: Port blockiert aktiv um Loops zu verhindern |

**5. Was ist STP (Spanning Tree Protocol)?**

Ein Protokoll das verhindert dass Loops in L2-Netzwerken entstehen. STP deaktiviert redundante Ports.
In Labs oft der Grund warum ein Port auf `disabled` oder `blocking` hängt.

**6. Wie siehst du ob ein Port an einer Bridge hängt — mit State?**

```bash
bridge link show
# oder
ip link show master <bridge-name>
```

**7. Was ist der Unterschied zwischen diesen beiden Befehlen?**

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
   → Ziel-MAC unbekannt → Flooding an alle Ports (veth-b-br)

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

### Aufgabe 1 — FDB beobachten

Baue das Setup aus Tag 20a auf (oder nutze ein neues Setup).

Bevor du pingst:
```bash
bridge fdb show br br0
```

Was siehst du? Erkläre jeden Eintrag.

Jetzt ping von ns-a nach ns-b, dann nochmal:
```bash
bridge fdb show br br0
```

Was hat sich geändert? Erkläre warum.

### Aufgabe 2 — Port State provozieren

Bringe das veth-Gegenstück eines Ports DOWN:
```bash
sudo ip link set veth-b-br down
```

Prüfe den Port State:
```bash
bridge link show
```

Was siehst du? Versuche von ns-a nach ns-b zu pingen — was passiert?

Bringe es wieder hoch und prüfe erneut.

### Aufgabe 3 — MAC-Learning Timeout beobachten

Nach einem Ping-Test:
```bash
bridge fdb show br br0
```

Notiere die dynamischen Einträge. Warte 5 Minuten (oder kürze mit `bridge fdb del` zum Testen).

Was passiert beim nächsten Ping? Beobachte mit:
```bash
sudo tcpdump -i br0 -n arp
```

Du solltest Flooding (ARP-Request auf allen Ports) sehen bevor der Eintrag wieder gelernt wird.

### Aufgabe 4 — `bridge link show` vs `ip link show master`

Vergleiche die Ausgabe beider Befehle. Was zeigt jeder — was fehlt beim anderen?

### Aufräumen

```bash
sudo ip netns delete ns-a
sudo ip netns delete ns-b
sudo ip link delete br0
```

---

## RZ Profi-Tipp

Im RZ mit physischen Switches und redundanten Uplinks ist STP/RSTP aktiv und kritisch. Ein falsch konfigurierter STP-Port kann einen ganzen Rack-Switch in `blocking` setzen. Der Befehl `bridge stp state <bridge>` zeigt den STP-Zustand — und `bridge monitor` zeigt live alle State-Änderungen. In Kubernetes-Umgebungen mit Cilium wird die Linux-Bridge oft ersetzt durch eBPF — aber das Grundverständnis bleibt dasselbe.
