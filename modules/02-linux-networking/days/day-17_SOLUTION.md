# Tag 17 — SOLUTION: iptables Grundlagen

## Aufgabe 1 — Aktuelle Regeln anzeigen

```bash
sudo iptables -L -v -n --line-numbers
```

Oder pro Tabelle:
```bash
sudo iptables -t filter -L -v -n --line-numbers
sudo iptables -t nat -L -v -n --line-numbers
sudo iptables -t mangle -L -v -n --line-numbers
```

**Was du siehst:**
- `pkts` / `bytes` — wie viele Pakete haben diese Regel getroffen
- `target` — was passiert mit dem Paket (ACCEPT, DROP, REJECT...)
- `prot` — Protokoll (tcp, udp, icmp, all)
- `in` / `out` — Interface
- `source` / `destination` — IP-Adressen

## Aufgabe 2 — Eingehende ICMP blockieren

```bash
sudo iptables -A INPUT -p icmp -j DROP
```

**DROP vs REJECT:**
- `DROP` — Paket wird still verworfen, Sender bekommt keine Antwort (Timeout)
- `REJECT` — Paket wird verworfen, Sender bekommt eine ICMP-Fehlermeldung zurück

Im RZ: `DROP` für externe Interfaces (gibt keine Info über die Firewall preis), `REJECT` intern (schnelleres Feedback für Debugging).

## Aufgabe 3 — Regel testen und entfernen

Testen:
```bash
ping -c 3 <host-ip>
# oder aus einem Namespace:
sudo ip netns exec ns1 ping -c 3 10.0.0.1
```

Entfernen — zwei Methoden:

**Methode 1: Per Zeilennummer**
```bash
sudo iptables -L INPUT --line-numbers
sudo iptables -D INPUT <nummer>
```

**Methode 2: Gleiche Regel mit -D statt -A**
```bash
sudo iptables -D INPUT -p icmp -j DROP
```

Alle Regeln einer Chain löschen:
```bash
sudo iptables -F INPUT
```

Alle Regeln aller Chains löschen:
```bash
sudo iptables -F
```

## Aufgabe 4 — FORWARD Chain verstehen

```bash
sudo iptables -L FORWARD -v -n
```

**Was du siehst:** Policy `ACCEPT` (Standard) — Traffic wird durchgelassen. Aber IP Forwarding muss im Kernel auch aktiviert sein:

```bash
cat /proc/sys/net/ipv4/ip_forward
# 0 = deaktiviert, 1 = aktiviert
```

Wenn `ip_forward = 0`, verwirft der Kernel Pakete die weitergeleitet werden sollen — noch bevor iptables sie sieht. Das ist der häufigste Grund warum Namespaces nicht ins Internet kommen.

## Aufgabe 5 — Conntrack

```bash
sudo conntrack -L
```

Nach einem Ping:
```
icmp     1 29 src=10.0.0.2 dst=10.0.0.1 type=8 code=0 id=12345 src=10.0.0.1 dst=10.0.0.2 type=0 code=0 id=12345 mark=0 use=1
```

**Was du siehst:**
- Protokoll, TTL (Sekunden bis der Eintrag gelöscht wird)
- Hin- und Rückrichtung des Pakets
- State: `NEW`, `ESTABLISHED`, `RELATED`

conntrack ist die Grundlage für Stateful Firewall — ohne es würde jedes Paket einzeln bewertet.

## Aufräumen

```bash
sudo iptables -F          # alle Rules löschen
sudo iptables -X          # alle User-Chains löschen
sudo iptables -P INPUT ACCEPT    # Policy zurücksetzen
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
```

## Mini-Quiz Antworten

1. **Paket von ns1 ins Internet:** PREROUTING (nat) → FORWARD (filter) → POSTROUTING (nat). Die INPUT Chain wird nicht durchlaufen — das Paket ist nicht für den Host bestimmt.

2. **`iptables -A INPUT -j DROP`:** SSH-Verbindungen werden ab sofort verworfen — bestehende Verbindungen auch (conntrack hilft hier nicht weil DROP keine Antwort sendet). Im schlimmsten Fall sperrst du dich aus dem Server aus.

3. **DROP vs REJECT im RZ:** DROP nach außen (gibt keine Angriffsfläche preis), REJECT intern zwischen Services (schnelleres Feedback, einfacheres Debugging). In Kubernetes-Clustern oft REJECT zwischen Pods für bessere Observability.
