# RZ Profi-Tipps — 100 Days Networking Challenge

> Gesammelte Profi-Tipps aus allen Tagen. Wächst mit jedem Tag mit.
> Ziel: Werkzeuge und Denkweisen die im RZ-Alltag und in Gesprächen mit Kollegen funktionieren.

---

## Denkmuster & Sprache

**`Network is unreachable` vs. Firewall:**
> *"`Network is unreachable` kommt vom Kernel, bevor das Paket überhaupt den Stack verlässt — da ist gar keine Firewall im Spiel."*
- `Network is unreachable` → Routing-Problem (fehlende Route)
- `Connection refused` / `timeout` → Firewall oder kein lauschender Prozess

**Isolation durch fehlende Konnektivität:**
> Isolation in Linux entsteht primär durch fehlende Konnektivität — nicht durch explizites Blockieren. Ein Namespace ohne Route ist wie ein Raum ohne Türen, nicht eine Tür mit Schloss.

**Port / Socket / Namespace — die Analogie:**
> Port ist eine Hausnummer. Socket ist die vollständige Adresse (Straße + Hausnummer + Stockwerk = IP + Port + Protokoll). Der Namespace ist das Gebäude — von außen kommt keiner rein ohne explizite Verbindung.

**Wo bin ich gerade?**
```bash
ip netns identify $$    # Leer = root namespace, sonst Namespace-Name
```

---

## Tag 12 — Routing & ARP

### Die drei häufigsten Routing-Fehler im RZ

| Nr. | Fehler | Symptom | Fix |
|-----|--------|---------|-----|
| 1 | Fehlende Default Route | "Network is unreachable" für alles außer lokales Netz | `ip route add default via <gateway>` |
| 2 | Falsches Gateway | Pakete gehen raus, Antworten kommen nicht zurück | `ip route show default` — Gateway muss im selben Subnetz sein |
| 3 | Source IP stimmt nicht | Server antwortet mit falscher Absender-IP | `ip route get <ziel>` zeigt welche Source-IP verwendet wird |

### ARP-Probleme bei MetalLB Failover
```
Node-A hat LoadBalancer-IP 10.0.1.100 → fällt aus
Node-B übernimmt → sendet Gratuitous ARP → alle Switches aktualisieren sofort
Ohne Gratuitous ARP: bis 15 Min. Traffic-Ausfall
```
```bash
ip neigh show | grep 10.0.1.100    # Richtige MAC hinterlegt?
```

### Asymmetrisches Routing erkennen
```bash
traceroute 10.0.5.42           # Hinweg
traceroute <eigene-IP>         # Rückweg (auf Zielserver ausführen)
```
Verschiedene Pfade → **asymmetrisches Routing** → Stateful Firewalls verwirrt → "Verbindung geht manchmal, manchmal nicht"

### MTU-Probleme finden
```bash
ping -M do -s 1472 -c 1 8.8.8.8    # Sollte klappen (1472 + 28 Header = 1500)
ping -M do -s 1473 -c 1 8.8.8.8    # Sollte fehlschlagen
```
**Symptom:** Ping geht, SCP/HTTP-Downloads hängen → MTU-Problem.
Mit VXLAN/Cilium: MTU auf 1450 reduziert (50 Byte VXLAN-Overhead).

---

## Tag 13 — `ip`-Befehl Komplett-Training

### Sofort-Check beim Login auf einen Node
```bash
ip -br -c a      # Welche IPs, welche Interfaces, was ist UP/DOWN?
ip r             # Default Gateway korrekt?
ss -tlnp         # Welche Services lauschen?
```
Diese drei Befehle dauern 2 Sekunden und geben dir sofort ein Bild vom Node-Zustand.

### Debug-Reihenfolge: "Server nicht erreichbar"
```bash
ip -br a                              # 1. Hat der Server eine IP?
ip -br link                           # 2. Ist das Interface UP?
ip route get <ziel-ip>                # 3. Stimmt die Route?
ip neigh show <gateway-ip>            # 4. Gateway per ARP bekannt?
ip -s link show enp0s1 | grep -i "drop\|error"  # 5. Paket-Drops?
```

### RX/TX Statistiken lesen
```bash
ip -s link show enp0s1
```
- `RX dropped > 0` → Interface-Buffer voll, zu viel Traffic → Ring-Buffer-Tuning oder schnellere NIC
- `TX errors > 0` → Kabel/Hardware-Problem oder Duplex-Mismatch
- `carrier > 0` → Link flaps — Kabel wackelt oder Switch-Port hat Probleme

### JSON-Output für Scripting
```bash
ip -j addr show enp0s1 | jq -r '.[0].addr_info[] | select(.family=="inet") | .local'
ip -j route show default | jq -r '.[0].gateway'
ip -j link show | jq -r '.[].ifname'
```

### `ip monitor` als Live-Debugging
```bash
ip monitor all      # Alle Änderungen live beobachten (Routen, ARP, Interfaces)
ip monitor route    # Nur Routing-Änderungen
ip monitor neigh    # Nur ARP-Änderungen (z.B. bei MetalLB-Failover)
```

---

## Tag 14 — Network Namespaces (`ip netns`)

### In den Netzwerk-Kontext eines laufenden Pods eintreten
```bash
crictl ps | grep <pod-name>           # Container-ID
crictl inspect <container-id> | grep pid   # PID des Containers
nsenter -t <pid> -n ip addr show      # Interface-Sicht des Pods
nsenter -t <pid> -n ip route show     # Routing-Tabelle des Pods
nsenter -t <pid> -n ss -tuln          # Lauschende Ports des Pods
```
**Warum besser als `kubectl exec`:** Funktioniert auch wenn der Container kein `ip`/`ss` installiert hat — du nutzt die Tools des Hosts, siehst aber die isolierte Routing-Domain des Pods. Auch bei crashenden Pods nutzbar.

### Kubernetes Namespace-Lifecycle
```
containerd startet Pod:
1. ip netns add <pod-id>        ← neue isolierte Routing-Domain
2. Cilium (CNI) wird gerufen
3. veth pair wird erstellt      ← ein Ende im Pod, eines im root namespace
4. IP wird im Pod konfiguriert
5. Route zum Pod im root namespace eingetragen
```
```bash
ls /var/run/netns/    # Alle benannten Namespaces auf dem Node
```

### Namespace-Isolation ≠ vollständige Security
Namespaces isolieren den Netzwerk-Stack — ein privilegierter Prozess kann ausbrechen.
Echte Isolation = Network Namespace + cgroups + Seccomp + AppArmor/SELinux.
Cilium NetworkPolicies bauen auf Namespace-Isolation auf und fügen L3/L4/L7-Filterung hinzu.

---

## Tag 19 — Container-Netzwerk von Null

### Vollständige Reihenfolge: Namespace ins Internet bringen
```
1. Namespace erstellen
2. Bridge erstellen + IP vergeben (10.0.0.1/24)
3. veth pair erstellen — ein Ende in den Namespace, ein Ende an die Bridge
4. IPs vergeben + Interfaces hochbringen
5. Default Route in den Namespace
6. IP Forwarding aktivieren
7. MASQUERADE-Regel setzen
```

---

## Tag 18 — NAT

### Packet-Counter als erster Debugging-Schritt
```bash
sudo iptables -t nat -L -v -n
```
`pkts` und `bytes` zeigen ob eine Regel überhaupt greift. Wenn eine Regel 0 Pakete zählt obwohl Traffic fließen sollte — falsche Chain, falsche Tabelle, oder Reihenfolge stimmt nicht.

### DNAT immer von extern testen
DNAT in `PREROUTING` greift nicht wenn du vom Host selbst auf die eigene IP curlst — der Kernel erkennt die eigene IP und umgeht PREROUTING. Für lokalen Traffic (vom Host selbst) braucht man zusätzlich eine Regel in der `OUTPUT` Chain:

| Traffic von | Chain |
|-------------|-------|
| Extern | `PREROUTING` |
| Lokal (Host selbst) | `OUTPUT` |

```bash
# Für externen Traffic
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:80
# Zusätzlich für lokalen Traffic
sudo iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 10.0.0.2:80
```
