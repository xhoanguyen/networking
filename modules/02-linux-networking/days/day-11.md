# Tag 11 — Linux Networking: Erste Schritte mit Multipass

## Setup (einmalig, ~15 Min)

Heute installieren wir Multipass und starten unsere erste Ubuntu-VM — die Umgebung die wir für Modul 02 durchgehend nutzen.

```bash
# Multipass installieren
brew install multipass

# Ubuntu-VM starten (heißt "rz-node")
multipass launch --name rz-node --cpus 2 --memory 2G --disk 10G

# In die VM einloggen
multipass shell rz-node

# Prüfen: Ubuntu-Version
cat /etc/os-release
```

## Lesen (20 Min)

Lies einen der folgenden Abschnitte — er gibt dir Kontext bevor wir die Commands ausprobieren:

**Theorie (wähle eine Quelle):**
- **Dordal Kap. 6** — Verbindungen, Interfaces, Encoding
- **Tanenbaum Kap. 1.4–1.5** — Protokollschichten, Standardisierung (präziser, akademischer)
- **Peterson & Davie Kap. 1.1–1.3** — Systems-Perspektive, warum Schichten existieren (empfohlen wenn du das "Warum" verstehen willst)

**Praxis (Pflicht für dieses Modul):**
- **LARTC — Linux Advanced Routing & Traffic Control** — das Standardwerk für `ip`, Routing, Namespaces. Von den iproute2-Entwicklern selbst. Kostenlos online: suche nach "LARTC Linux Advanced Routing Traffic Control".

Fokus: Was ist ein Netzwerk-Interface? Was ist der Unterschied zwischen physischem und virtuellem Interface?

## Lab: ip-Commands (30 Min)

Alle folgenden Commands in der Multipass-VM ausführen (`multipass shell rz-node`):

### 1. Interfaces anzeigen

```bash
# Alle Interfaces
ip link show

# Nur aktive Interfaces
ip link show up

# Details zu einem Interface (ersetze eth0 durch deinen Interface-Namen)
ip link show eth0
```

**Dokumentiere:**
- Wie viele Interfaces siehst du?
- Was ist der Unterschied zwischen `lo` und `eth0`?
- Was bedeutet `state UP`?

### 2. IP-Adressen

```bash
# Alle IP-Adressen
ip addr show

# Nur ein Interface
ip addr show eth0
```

**Dokumentiere:**
- Welche IP hat deine VM?
- Was ist die Subnetzmaske (in CIDR-Notation)?
- Was ist `127.0.0.1` und warum ist es immer da?

### 3. Routing-Tabelle

```bash
# Routing-Tabelle anzeigen
ip route show

# Wer ist mein Gateway?
ip route show default
```

**Dokumentiere:**
- Was ist dein Default Gateway?
- Was bedeutet `proto dhcp`?

### 4. ARP-Tabelle

```bash
# Welche MAC-Adressen kennt mein System?
ip neigh show
```

**Dokumentiere:**
- Welche Einträge siehst du?
- Was bedeutet `REACHABLE` vs `STALE`?

### 5. Verbindungen testen

```bash
# Erreichbarkeit testen
ping -c 3 8.8.8.8

# Route zu einem Ziel verfolgen
traceroute 8.8.8.8

# Aktive Verbindungen anzeigen
ss -tuln
```

**Dokumentiere:**
- Welche Ports lauschen auf deiner VM (`ss -tuln`)?
- Wie viele Hops bis 8.8.8.8?

## Reflexion

- [ ] Was ist der Unterschied zwischen `ip addr` und `ifconfig`?
- [ ] Wozu braucht man das `lo`-Interface?
- [ ] Was würde passieren wenn kein Default Gateway gesetzt wäre?

## RZ-Verbindung

Diese Commands sind dein tägliches Handwerkszeug auf einem RKE2-Node:
- `ip addr` → welche IPs hat der Node?
- `ip route` → wie wird Traffic geroutet?
- `ip neigh` → ARP-Tabelle debuggen (relevant bei MetalLB L2-Mode)
- `ss -tuln` → welche Services lauschen?
