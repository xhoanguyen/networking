# Tag 14 — Network Namespaces: Das Fundament von Container-Networking

## What are we doing today and why?

Heute geht es um **Network Namespaces** (`ip netns`) — das wahrscheinlich wichtigste Konzept in diesem Modul. Jeder Pod in Kubernetes lebt in seinem eigenen Network Namespace. Wenn du das einmal manuell aufgebaut hast, wird Cilium, CNI und Container-Networking auf einmal sehr greifbar.

**Warum:** Ohne Network Namespaces kein Container-Networking. Cilium, containerd, Flannel — sie alle bauen auf `ip netns` auf. Wer das einmal manuell gemacht hat, versteht danach sofort, was passiert wenn ein Pod nicht erreichbar ist.

## Lesen (15 Min)

**Pflicht:**
- **`man ip-netns`** — direkt in der VM: `man ip netns` — die wichtigste Primärquelle, vollständig und präzise
- **Dordal, Kap. Virtuelle Netzwerke** — *"Wenn ein Computer eine virtuelle Maschine hostet, gibt es fast immer ein virtuelles Netzwerk"* und *"Der Host verfügt über eine virtuelle Schnittstelle"* — gutes Fundament für das veth-Konzept das morgen (Tag 15) kommt

**Optional:**
- **Zisler — FreeBSD Jails** — gute Analogie: *"Jedes Jail verfügt über eine eigene IP-Adresse und wird in fast allen Punkten so konfiguriert, als wäre es ein eigenständiger Rechner"* — das ist konzeptionell genau was ein Network Namespace macht
- **Michael Kerrisk — "Namespaces in Operation"** (LWN.net, 7-teilige Serie) — die beste tiefgehende Referenz zu Linux Namespaces überhaupt, von dem Mann der `man`-Pages schreibt
- **"Container Networking from Scratch"** — praktischer Walk-through: manuell veth pair + netns + bridge aufbauen — perfekte Vorbereitung für Tag 15-16

## Kernkonzepte

- [ ] Ein **Network Namespace** ist eine vollständig isolierte Kopie des Linux-Netzwerk-Stacks — eigene Interfaces, eigene Routing-Tabelle, eigene iptables-Regeln, eigene Sockets
- [ ] Beim Start hat jede Linux-VM einen einzigen Namespace: den **root namespace** (auch "default namespace") — dort laufen alle normalen Prozesse
- [ ] Mit `ip netns add <name>` erstellst du einen neuen, leeren Namespace — er enthält nur `lo` (loopback), und der ist zunächst `DOWN`
- [ ] Jeder Kubernetes Pod bekommt beim Start einen eigenen Namespace — das ist der Grund, warum Pods sich nicht gegenseitig sehen (außer über das Netzwerk)
- [ ] Prozesse können in einem Namespace gestartet werden: `ip netns exec <name> <command>` — der Prozess sieht dann nur das Netzwerk dieses Namespace
- [ ] Um zwei Namespaces zu verbinden, braucht man **veth pairs** (kommt Tag 15) — ein virtuelles Kabel mit zwei Enden

## Flashcards

**Q:** Was wird in einem Network Namespace isoliert?
**A:** Der komplette Linux-Netzwerk-Stack: Interfaces, Routing-Tabellen, iptables-Regeln, Netfilter-Hooks und Sockets. Jeder Pod kann Port 8080 nutzen weil jeder seinen eigenen isolierten Socket-Stack hat — also seinen eigenen Network Namespace.

> **Analogie:** Port ist eine Hausnummer, Socket ist die vollständige Adresse (Straße + Hausnummer + Stockwerk = IP + Port + Protokoll). Der Namespace ist das Gebäude — von außen kommt keiner rein ohne explizite Verbindung.

**Q:** Warum startet ein neuer Namespace mit nur `lo`, und warum ist es `DOWN`?
**A:** Ein frischer Namespace ist komplett leer — der Kernel gibt dir nur das Loopback-Interface als Minimum. Es ist `DOWN`, weil niemand es aktiviert hat. Du musst explizit `ip netns exec <name> ip link set lo up` ausführen.

**Q:** Was ist der Unterschied zwischen `ip netns exec` und `nsenter`?
**A:** `ip netns exec` wechselt nur in den Network Namespace eines benannten Namespace (der in `/var/run/netns/` liegt). `nsenter` kann in jeden Namespace-Typ eintreten (net, pid, mnt, uts) und funktioniert auch für laufende Prozesse per PID — das ist der Befehl, den man im RZ nutzt um in einen laufenden Pod-Namespace zu schauen.

## Lab: Network Namespaces erstellen und erkunden (30 Min)

Alle Commands in der Multipass-VM (`multipass shell rz-node`):

### Aufgabe 1 — Namespace erstellen und erkunden

Bevor du den Befehl ausführst: Was erwartest du in einem frisch erstellten Network Namespace zu sehen? Wie viele Interfaces, und in welchem Zustand?

```bash
# Neuen Namespace erstellen
sudo ip netns add lab-ns1

# Alle Namespaces anzeigen
ip netns list

# Interfaces im neuen Namespace anzeigen
sudo ip netns exec lab-ns1 ip link show

# Routing-Tabelle des neuen Namespace
sudo ip netns exec lab-ns1 ip route show
```

**Dokumentiere:**
- [ ] Wie viele Interfaces siehst du im neuen Namespace? Welchen Zustand haben sie?
- [ ] Was zeigt `ip route show` im neuen Namespace? Warum?
- [ ] Was ist der Unterschied zu `ip link show` im root namespace?

---

### Aufgabe 2 — Netzwerk im Namespace konfigurieren

Bevor du weiter machst: Kannst du `ping 127.0.0.1` direkt im neuen Namespace ausführen, ohne lo zu aktivieren? Was passiert deiner Meinung nach?

```bash
# Loopback aktivieren
sudo ip netns exec lab-ns1 ip link set lo up

# Prüfen
sudo ip netns exec lab-ns1 ip link show lo

# Ping auf Loopback im Namespace
sudo ip netns exec lab-ns1 ping -c 2 127.0.0.1

# Kannst du von hier die Host-IP erreichen?
# Zuerst Host-IP rausfinden:
ip addr show enp0s1 | grep "inet "

# Dann im Namespace versuchen:
sudo ip netns exec lab-ns1 ping -c 2 <host-ip>
```

**Dokumentiere:**
- [ ] Was passiert bei `ping 127.0.0.1` vor und nach `ip link set lo up`?
- [ ] Kommt der Ping zur Host-IP durch? Warum (nicht)?
- [ ] Was sagt das über die Isolation von Namespaces aus?

---

### Aufgabe 3 — Eine Shell im Namespace starten

Das ist wie es Container machen: ein Prozess in einem isolierten Netzwerk-Kontext. Bevor du es ausführst — was erwartest du bei `ip link show` innerhalb dieser Shell zu sehen?

```bash
# Bash-Shell direkt im Namespace starten
sudo ip netns exec lab-ns1 bash

# Ab hier bist du "im Namespace" — prüfe:
ip link show
ip route show
ip addr show

# Versuche den root namespace von hier aus zu sehen:
# (Spoiler: geht nicht)
ip link show enp0s1

# Shell beenden
exit

# Aufräumen: Namespace löschen
sudo ip netns delete lab-ns1

# Prüfen ob er weg ist
ip netns list
```

**Dokumentiere:**
- [ ] Was siehst du bei `ip link show` innerhalb der Namespace-Shell?
- [ ] Kannst du `enp0s1` aus dem Namespace heraus sehen? Was bedeutet das?
- [ ] Was passiert mit dem Namespace-Netzwerk wenn du `exit` tippst?

## Profi-Wissen für den RZ-Alltag

### In einen laufenden Pod-Namespace schauen

Das brauchst du bei Debugging fast täglich:

```bash
# Pod-Name und Namespace
kubectl get pod <pod-name> -n <namespace> -o wide

# Container-PID auf dem Node rausfinden
crictl inspect <container-id> | grep pid

# In den Netzwerk-Namespace des Containers eintreten
nsenter -t <pid> -n ip addr show
nsenter -t <pid> -n ip route show
nsenter -t <pid> -n ss -tuln
```

**Warum besser als `kubectl exec`:** `nsenter` gibt dir denselben Netzwerk-Kontext wie der Pod — aber mit den Tools des Hosts. Du kannst `tcpdump` laufen lassen, auch wenn der Container kein tcpdump installiert hat.

### Wie Kubernetes Namespaces anlegt

```
containerd startet Pod:
1. ip netns add <pod-id>          ← neuer Namespace für den Pod
2. CNI-Plugin (Cilium) wird aufgerufen
3. Cilium erstellt ein veth pair   ← ein Ende in den Pod-Namespace, eines in den root namespace
4. IP-Adresse wird im Pod-Namespace konfiguriert
5. Route zum Pod wird im root namespace eingetragen
```

Du kannst das auf einem RKE2-Node live sehen:

```bash
# Alle Namespaces auf dem Node (braucht root)
ip netns list

# Oder direkt:
ls /var/run/netns/
```

### Namespace-Isolation als Security-Konzept

Namespaces sind kein Security-Feature per se — sie isolieren den Netzwerk-Stack, aber ein privilegierter Prozess kann trotzdem ausbrechen. **Echte Isolation** kommt erst durch die Kombination aus: Network Namespace + cgroups + Seccomp + AppArmor/SELinux.

Im RZ-Kontext: Cilium NetworkPolicies setzen auf Namespace-Isolation auf und fügen L3/L4/L7-Filterung obendrauf.

## Mini-Quiz (Theorie)

1. **Was genau wird in einem Network Namespace isoliert?** Nenne mindestens drei Dinge — und erkläre warum gerade diese Isolation wichtig für Container ist.

2. **Warum hat jeder Kubernetes Pod seinen eigenen Network Namespace?** Was wäre das Problem, wenn sich zwei Pods einen Namespace teilen würden?

3. **Du willst von außen in den Netzwerk-Kontext eines laufenden Pods schauen — ohne `kubectl exec`.** Welchen Befehl nutzt du, und was brauchst du dafür?

## Reflexion

- [ ] Ich kann einen Namespace erstellen, konfigurieren und wieder löschen
- [ ] Ich verstehe warum ein frischer Namespace nur `lo` (DOWN) enthält
- [ ] Ich weiß wie man einen Prozess in einem Namespace startet (`ip netns exec`)
- [ ] Ich verstehe den Zusammenhang zwischen Namespaces und Kubernetes Pods
- [ ] Ich weiß wie man mit `nsenter` in einen laufenden Container-Namespace einsteigt

## Faustregeln

**Namespace-Befehle:**
- `ip netns add <name>` → Namespace erstellen
- `ip netns list` → alle Namespaces anzeigen
- `ip netns exec <name> <cmd>` → Befehl im Namespace ausführen
- `ip netns delete <name>` → Namespace löschen

**Pod-Debugging:**
- `nsenter -t <pid> -n` → in Netzwerk-Namespace eines laufenden Prozesses eintreten
- `ls /var/run/netns/` → alle benannten Namespaces auf dem Node

**Merksatz:** *Ein Network Namespace = eine vollständig isolierte Netzwerkumgebung. Kein Interface, keine Route, kein Port überlebt die Grenze — außer du baust explizit eine Verbindung.*
