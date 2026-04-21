# Tag 16 — Linux Bridge: Mehrere Namespaces verbinden

## What are we doing today and why?

Gestern hast du zwei Namespaces über ein veth pair verbunden — das funktioniert für genau zwei. Was aber wenn du drei, fünf oder hundert Namespaces hast? Ein veth pair pro Paar würde schnell unhandlich. Die Lösung: eine **Linux Bridge** — ein virtueller Switch im Kernel. Genau das nutzt Docker für seine Container-Netzwerke (`docker0`) und Kubernetes-Node-Netzwerke.

**Warum:** Eine Bridge verhält sich wie ein physischer Layer-2-Switch: sie lernt MAC-Adressen, leitet Frames gezielt weiter und verbindet beliebig viele Interfaces miteinander. Wer versteht wie eine Bridge funktioniert, versteht warum `docker0` existiert und wie Pod-to-Pod Traffic auf demselben Node fließt.

## Lesen (20 Min)

**Pflicht:**
- **`man ip-link`** (auf der VM) — offizielle Referenz für alle `ip link`-Befehle inkl. Bridge-Typen und `master`-Keyword
- **`man bridge`** (auf der VM) — Bridge-spezifische Befehle wie `bridge fdb show`
- **LARTC Kapitel 4** — Routing Policy Database, wie Traffic in die Bridge geleitet wird
- **Dordal — Virtuelle Netzwerke** — Bridge als virtueller Switch, MAC-Learning

**Optional:**
- **"Understanding Linux Network Internals"** — Christian Benvenuti (O'Reilly) — Kernel-Ebene Bridge-Implementierung
- **"Linux Network Administrator's Guide"** — Tony Bautts et al. (O'Reilly) — praktische Bridge-Konfiguration
- **"Container Networking from Scratch"** — Bridge-Setup mit mehreren Namespaces

## Kernkonzepte

- [ ] Eine **Linux Bridge** ist ein virtueller Layer-2-Switch im Kernel — sie arbeitet mit MAC-Adressen, nicht mit IPs
- [ ] Interfaces werden der Bridge als **Ports** hinzugefügt — ähnlich wie Kabel in einen Switch stecken
- [ ] Die Bridge selbst kann eine IP bekommen — dann ist sie das Gateway für alle angeschlossenen Namespaces
- [ ] **MAC-Learning:** die Bridge lernt automatisch welches Interface hinter welcher MAC-Adresse liegt
- [ ] Jeder Namespace bekommt ein veth pair — ein Ende an die Bridge, das andere in den Namespace
- [ ] In Docker heißt die Bridge `docker0`, in Kubernetes ist es oft `cni0` oder `cbr0`

## Flashcards

**Q:** Was ist der Unterschied zwischen einem veth pair und einer Linux Bridge?
**A:** Ein veth pair verbindet genau zwei Endpunkte — wie ein Kabel. Eine Bridge verbindet beliebig viele Endpunkte — wie ein Switch. Für N Namespaces brauchst du N veth pairs, aber nur eine Bridge.

**Q:** Auf welchem Layer arbeitet eine Linux Bridge?
**A:** Layer 2 — sie lernt MAC-Adressen und leitet Ethernet-Frames weiter. IP-Adressen sind ihr egal, solange kein Routing nötig ist. Wenn die Bridge selbst eine IP hat, kann sie als Gateway für die angeschlossenen Namespaces fungieren.

**Q:** Warum hat `docker0` eine IP-Adresse, obwohl eine Bridge ein Layer-2-Gerät ist?
**A:** Weil die Bridge-Interface im Linux-Netzwerk-Stack gleichzeitig ein Layer-3-Interface sein kann. Docker gibt `docker0` eine IP (z.B. 172.17.0.1) damit der Host als Gateway für die Container erreichbar ist — und damit Container über den Host ins Internet routen können.

**Q:** Was passiert mit dem Traffic wenn zwei Namespaces an derselben Bridge hängen?
**A:** Der Traffic bleibt auf Layer 2 — die Bridge leitet den Frame direkt vom Sender zum Empfänger, ohne dass der Host-IP-Stack involviert ist. Kein Routing nötig, solange beide im selben Subnetz sind.

## Lab: Linux Bridge bauen und drei Namespaces verbinden

Alle Commands in der Multipass-VM (`multipass shell rz-node`).

**Ziel heute:** Drei isolierte Namespaces über eine Linux Bridge verbinden — wie drei Container hinter `docker0`.

```
ns1              ns2              ns3
  │                │                │
veth-ns1         veth-ns2         veth-ns3
  │                │                │
veth-ns1-br      veth-ns2-br      veth-ns3-br
  │                │                │
  └──────────── br0 (bridge) ───────┘
                    │
               10.0.0.1/24 (Gateway)
```

---

### Aufgabe 1 — Bridge erstellen

Bevor du den Befehl ausführst: Mit welchem `ip link` Type erstellst du eine Bridge? Und was musst du danach noch tun damit sie aktiv ist?

---

### Aufgabe 2 — Namespaces und veth pairs

Du brauchst drei Namespaces (`ns1`, `ns2`, `ns3`) und drei veth pairs. Wie verbindest du ein veth-Ende mit der Bridge?

Denk nach: Was bedeutet "Port an einem Switch"? Was ist das Äquivalent im Linux-Kontext?

---

### Aufgabe 3 — IPs vergeben und aktivieren

Die Bridge bekommt eine IP (`10.0.0.1/24`) — sie ist das Gateway. Die Namespaces bekommen `10.0.0.2`, `10.0.0.3`, `10.0.0.4`.

Brauchen die veth-Enden an der Bridge eine IP? Warum oder warum nicht?

---

### Aufgabe 4 — Ping zwischen allen Namespaces

Teste alle Kombinationen:
- ns1 → ns2
- ns1 → ns3
- ns2 → ns3
- Jeder Namespace → Bridge (Gateway)

Was erwartest du bei `ip route show` in einem Namespace?

---

### Aufgabe 5 — MAC-Learning beobachten

Schau in die Bridge-FDB (Forwarding Database) bevor und nach einem Ping:

```bash
bridge fdb show br br0
```

Was verändert sich? Was bedeutet das?

---

### Aufräumen

Lösche alle drei Namespaces (`ns1`, `ns2`, `ns3`) und prüfe ob die Bridge automatisch verschwindet oder manuell gelöscht werden muss.

## Mini-Quiz (Theorie)

1. **Du hast fünf Container auf einem Host, alle sollen miteinander kommunizieren.** Wieviele veth pairs brauchst du, und wie viele Bridges?

2. **Ein Container kann andere Container auf demselben Host pingen, aber nicht das Internet.** Was fehlt wahrscheinlich?

3. **`bridge fdb show` zeigt eine MAC-Adresse mit `master br0`.** Was bedeutet das?

## Reflexion

- [ ] Ich kann eine Linux Bridge erstellen und Interfaces als Ports hinzufügen
- [ ] Ich verstehe warum die Bridge eine IP bekommt und die Port-Interfaces nicht
- [ ] Ich kann drei Namespaces über eine Bridge zum gegenseitigen Pingen bringen
- [ ] Ich verstehe was MAC-Learning bedeutet und wie `bridge fdb` es zeigt
- [ ] Ich erkenne den Zusammenhang zwischen Linux Bridge und `docker0`

## Faustregeln

**Bridge:**
- Bridge = virtueller Switch (Layer 2)
- Bridge-Interface kann auch IP haben (Layer 3 Gateway)
- Port-Interfaces (veth-Enden an der Bridge) brauchen keine IP

**Debugging:**
- `bridge fdb show` → MAC-Tabelle der Bridge
- `ip link show master br0` → alle Interfaces die an br0 hängen
- Bridge DOWN? → `ip link set br0 up`

**Merksatz:** *Eine Bridge verbindet viele — ein veth pair verbindet zwei. Docker0 ist nichts anderes als eine Linux Bridge mit einer IP.*
