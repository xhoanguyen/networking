# Tag 15 — veth Pairs: Namespaces verbinden

## What are we doing today and why?

Gestern hast du Network Namespaces erstellt — aber sie waren komplett isoliert, keine Verbindung nach außen. Heute baust du die Brücke: **veth pairs** (Virtual Ethernet Pairs). Ein veth pair ist ein virtuelles Kabel mit zwei Enden — jedes Ende kann in einem anderen Namespace leben. Das ist exakt der Mechanismus, den Kubernetes und containerd nutzen um Pods mit dem Host zu verbinden.

**Warum:** Jedes Mal wenn Kubernetes einen Pod startet, erstellt das CNI-Plugin (bei dir: Cilium) ein veth pair — ein Ende landet im Pod-Namespace, das andere im root namespace des Nodes. Ohne das Konzept ist Pod-Networking eine Black Box.

## Lesen (20 Min)

**Pflicht:**
- **LARTC Kapitel 4 — Rules: Routing Policy Database (RPDB)** — erklärt wie Linux entscheidet, *welche* Routing-Tabelle überhaupt konsultiert wird, bevor eine Route gesucht wird. Cilium legt für jeden Pod eigene `ip rule`-Einträge an — das ist der Grund
- **Dordal — Virtuelle Netzwerke und Schnittstellen** — *"Der Host verfügt über eine virtuelle Schnittstelle zur Verbindung mit dem virtuellen Netzwerk. Er kann als NAT-Router fungieren oder als Ethernet-Switch"* — direkte konzeptuelle Basis für veth pairs

**Optional:**
- **"Container Networking from Scratch"** — walk-through der exakt das macht was du heute im Terminal machst: veth + netns + bridge

## Kernkonzepte

- [ ] Ein **veth pair** besteht immer aus *zwei* Interfaces — sie sind untrennbar miteinander verbunden: was auf einem Ende reingeht, kommt am anderen Ende raus
- [ ] Bei `ip link add veth0 type veth peer name veth1` vergibt `peer name veth1` dem **anderen Ende des Kabels** einen Namen — ohne `peer name` wählt der Kernel einen automatischen Namen. Die Namen sind nur Konvention, keine technische Verpflichtung.
- [ ] Du kannst jedes Ende eines veth pairs in einen anderen Namespace verschieben: `ip link set <veth-end> netns <namespace>`
- [ ] Erst wenn **beide Enden `UP`** sind und **IP-Adressen** haben, fließt Traffic
- [ ] Ein veth pair allein reicht für zwei Namespaces — für mehr Namespaces braucht man eine **Linux Bridge** (kommt Tag 16)
- [ ] In Kubernetes: ein Ende heißt typischerweise `vethXXXXXX` im root namespace, das andere Ende heißt `eth0` im Pod-Namespace
- [ ] Die RPDB (`ip rule`) entscheidet *bevor* `ip route` greift — Priorität 0 (local) → 32766 (main) → 32767 (default). Cilium fügt eigene Rules mit niedrigen Prioritäten ein um Pod-Traffic zu steuern

## Flashcards

**Q:** Was passiert wenn nur ein Ende eines veth pairs `UP` ist?
**A:** Kein Traffic — beide Enden müssen `UP` sein. Es verhält sich wie ein physisches Kabel: wenn einer den Stecker zieht, ist die Verbindung tot. Das ist auch der Grund warum ein Pod keine Netzwerkverbindung hat, wenn das veth-Ende im root namespace `DOWN` ist.

**Q:** Was ist der Unterschied zwischen `ip link add` und `ip link set ... netns`?
**A:** `ip link add` erstellt das veth pair im aktuellen Namespace (root). `ip link set <interface> netns <name>` verschiebt ein Interface in einen anderen Namespace — danach ist es im ursprünglichen Namespace unsichtbar. Das ist keine Kopie, das Interface wandert wirklich.

**Q:** Warum sieht Kubernetes-Pod `eth0` im Pod, aber `vethXXXXXX` auf dem Node?
**A:** Es ist dasselbe veth pair — nur die Enden haben verschiedene Namen. Das CNI-Plugin benennt das Ende im Pod-Namespace zu `eth0` um (per `ip link set veth1 name eth0`), das Host-Ende behält seinen generierten Namen. So hat jeder Pod ein übliches `eth0`, obwohl es intern ein veth pair ist.

**Q:** Was macht `ip rule` und warum ist es wichtiger als `ip route`?
**A:** `ip rule` ist die Routing Policy Database (RPDB) — sie bestimmt *welche Routing-Tabelle* für ein Paket konsultiert wird, basierend auf Source-IP, Destination-IP oder fwmark. Erst danach greift `ip route` in der gewählten Tabelle. In Kubernetes legt Cilium eigene ip-rules an (z.B. für Pod-CIDRs), die vor der main-Tabelle greifen.

## Lab: veth Pairs bauen und zwei Namespaces verbinden (35 Min)

Alle Commands in der Multipass-VM (`multipass shell rz-node`).

**Ziel heute:** Zwei isolierte Namespaces so verbinden, dass sie sich gegenseitig pingen können — exakt wie zwei Pods auf demselben Node.

### Aufgabe 1 — veth pair erstellen und aufteilen

Bevor du den Befehl ausführst: Ein veth pair wird immer im root namespace erstellt. Wie kannst du danach ein Ende in einen anderen Namespace verschieben — und was passiert mit dem anderen Ende?

```bash
# Zwei Namespaces erstellen
sudo ip netns add ns-rot
sudo ip netns add ns-blau

# veth pair erstellen (beide Enden landen zunächst im root namespace)
sudo ip link add veth-rot type veth peer name veth-blau

# Prüfen: beide Interfaces im root namespace sichtbar?
ip link show type veth

# Je ein Ende in den jeweiligen Namespace verschieben
sudo ip link set veth-rot netns ns-rot
sudo ip link set veth-blau netns ns-blau

# Was siehst du jetzt noch im root namespace?
ip link show type veth
```

**Dokumentiere:**
- [ ] Was zeigt `ip link show type veth` vor dem Verschieben?
- [ ] Was zeigt es *nach* dem Verschieben? Warum sind die Interfaces verschwunden?
- [ ] Was sagt das über die Natur von veth pairs aus?

---

### Aufgabe 2 — IPs konfigurieren und Interfaces aktivieren

Bevor du weitermachst: Was muss alles stimmen, damit ein Ping zwischen den zwei Namespaces funktioniert? Denk an Interfaces, IPs, und Routing.

```bash
# Loopback und veth in ns-rot aktivieren + IP setzen
sudo ip netns exec ns-rot ip link set lo up
sudo ip netns exec ns-rot ip link set veth-rot up
sudo ip netns exec ns-rot ip addr add 10.0.0.1/24 dev veth-rot

# Dasselbe für ns-blau
sudo ip netns exec ns-blau ip link set lo up
sudo ip netns exec ns-blau ip link set veth-blau up
sudo ip netns exec ns-blau ip addr add 10.0.0.2/24 dev veth-blau

# Status prüfen
sudo ip netns exec ns-rot ip addr show
sudo ip netns exec ns-blau ip addr show
```

**Dokumentiere:**
- [ ] Welche IP hat welcher Namespace?
- [ ] Welchen Zustand haben die Interfaces (UP/DOWN)?
- [ ] Braucht man eine explizite Route oder reicht die IP-Konfiguration? Warum?

---

### Aufgabe 3 — Ping und Verbindung verifizieren

Jetzt der Moment der Wahrheit. Bevor du pingst: In welche Richtung pingst du zuerst, und was erwartest du?

```bash
# Ping von ns-rot nach ns-blau
sudo ip netns exec ns-rot ping -c 3 10.0.0.2

# Ping von ns-blau nach ns-rot
sudo ip netns exec ns-blau ping -c 3 10.0.0.1

# Routing-Tabelle in beiden Namespaces anschauen
sudo ip netns exec ns-rot ip route show
sudo ip netns exec ns-blau ip route show

# Aufräumen
sudo ip netns delete ns-rot
sudo ip netns delete ns-blau
# (veth pairs werden automatisch gelöscht wenn der Namespace gelöscht wird)
```

**Dokumentiere:**
- [ ] Funktioniert der Ping? Wenn ja — welche Route macht das möglich?
- [ ] Was zeigt `ip route show` in den Namespaces? Hat jemand diese Route manuell angelegt?
- [ ] Was passiert mit dem veth pair wenn du den Namespace löschst?

## Profi-Wissen für den RZ-Alltag

### Pod-Netzwerk auf einem RKE2-Node nachverfolgen

```bash
# Alle veth pairs auf dem Node anzeigen
ip link show type veth

# Zu welchem Pod gehört welches veth?
# Option 1: über die Index-Nummer
ip link show vethXXXXXX

# Option 2: in den Pod-Namespace einsteigen und von innen schauen
kubectl get pod <pod> -n <ns> -o wide   # Node rausfinden
crictl ps | grep <pod-name>              # Container-ID
crictl inspect <id> | grep pid           # PID des Containers
nsenter -t <pid> -n ip link show eth0    # eth0 im Pod-Namespace
# ifindex von eth0 merken, dann im root namespace:
ip link | grep "^<ifindex>:"             # Das ist das Host-Ende des veth pairs
```

### RPDB in Kubernetes verstehen

```bash
# ip rules auf einem K8s-Node
ip rule show

# Typische Ausgabe mit Cilium:
# 0:      from all lookup local
# 100:    from all fwmark 0x200/0xf00 lookup 2048     ← Cilium: Pod-Traffic
# 32766:  from all lookup main
# 32767:  from all lookup default
```

Die Cilium-Rules mit Priorität 100 greifen *vor* der main-Tabelle — so kann Cilium den Pod-Traffic in seine eigenen Routing-Tabellen umleiten, ohne die normale Routing-Tabelle anzufassen.

### Debugging: veth pair ist DOWN — Pod hat kein Netzwerk

```bash
# Symptom: Pod läuft, aber kein Netzwerk
# Schritt 1: Host-Ende des veth pairs prüfen
ip link show type veth | grep -A1 <pod-veth-name>

# Schritt 2: Ist es DOWN?
ip link set <veth-name> up

# Warum passiert das? Manchmal bringt ein Node-Restart veth interfaces in DOWN-Zustand
# Cilium stellt das normalerweise automatisch wieder her
```

## Mini-Quiz (Theorie)

1. **Du erstellst ein veth pair mit `ip link add veth0 type veth peer name veth1`.** Wo leben beide Interfaces danach, und was musst du als nächstes tun damit zwei Namespaces darüber kommunizieren können?

2. **`ip rule show` auf einem Node zeigt eine Regel mit Priorität 100, bevor die `main`-Tabelle (32766) kommt.** Was bedeutet das — und warum macht Cilium das?

3. **Ein Pod hat kein Netzwerk, obwohl er `Running` ist.** Du schaust auf dem Node und siehst das veth-Interface ist `DOWN`. Welcher Befehl behebt das, und was könnte die Ursache sein?

## Reflexion

- [ ] Ich kann ein veth pair erstellen und die Enden in verschiedene Namespaces verschieben
- [ ] Ich verstehe warum beide Enden UP sein müssen
- [ ] Ich kann zwei Namespaces über ein veth pair zum Pingen bringen
- [ ] Ich weiß wie ein Kubernetes Pod über veth pairs mit dem Node verbunden ist
- [ ] Ich verstehe den Unterschied zwischen `ip rule` (RPDB) und `ip route`

## Faustregeln

**veth pairs:**
- Immer zu zweit — kein einzelnes veth ohne sein Gegenstück
- Im root namespace erstellen, dann Enden verschieben
- Beide Enden müssen UP sein + IP haben + im selben Subnetz liegen

**RPDB:**
- `ip rule show` → Prioritäten lesen (niedrigere Zahl = höhere Priorität)
- `ip rule` greift *vor* `ip route`
- Cilium nutzt eigene Rules (Prio ~100) um Pod-Traffic abzufangen

**Pod-Debugging:**
- veth DOWN → `ip link set <veth> up`
- Welches veth gehört zu welchem Pod → `nsenter -t <pid> -n ip link show eth0` + ifindex abgleichen

**Merksatz:** *Ein veth pair ist ein virtuelles Netzwerkkabel. Du kannst jedes Ende in einen anderen Namespace stecken — genau das macht Kubernetes für jeden Pod.*
