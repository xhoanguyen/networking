# Tag 12 — Linux Routing & ARP vertiefen

## What are we doing today and why?

Gestern hast du `ip addr`, `ip route`, `ip neigh` und `ss` kennengelernt. Heute vertiefst du **Routing-Tabellen** und **ARP-Verhalten** — die zwei Mechanismen, die im RZ am häufigsten Probleme verursachen, wenn man sie nicht versteht.

**Warum:** Wenn ein Pod nicht erreichbar ist, liegt es in 80% der Fälle an falschem Routing oder stale ARP-Einträgen. Wer diese zwei Konzepte auf Linux-Ebene beherrscht, findet Fehler in Minuten statt Stunden.

## Lesen (20 Min)

**Pflicht:**
- **LARTC Kapitel 4** — Rules: Routing Policy Database (RPDB). Erklärt, warum Linux nicht nur eine Routing-Tabelle hat, sondern drei (`local`, `main`, `default`).
- **LARTC Kapitel 3.5** — ARP: Zustände im Neighbor-Cache (`reachable`, `stale`, `delay`, `probe`, `failed`).

**Optional:**
- **Dordal Kap. 1.3-1.4** — Datagrammweiterleitung: wie Router Pakete anhand der Tabelle forwarden.

## Kernkonzepte

### Routing

- [ ] Linux hat **drei Routing-Tabellen**: `local` (eigene IPs), `main` (normale Routen), `default` (leer, für Policy-Routing reserviert)
- [ ] `ip route show` zeigt nur die `main`-Tabelle — `ip route show table local` zeigt die anderen
- [ ] **Longest Prefix Match**: bei mehreren passenden Einträgen gewinnt der spezifischste (`/32` schlägt `/24` schlägt `/0`)
- [ ] `proto dhcp` = Route wurde per DHCP gelernt, `proto kernel` = vom Kernel automatisch angelegt (direkt verbundenes Netz)
- [ ] `scope link` = nur im lokalen Segment gültig (kein Gateway nötig)

### ARP (Neighbor Cache)

- [ ] ARP übersetzt IP → MAC im lokalen Segment (Layer 3 → Layer 2)
- [ ] ARP-Einträge haben **Zustände**: `REACHABLE` (frisch bestätigt) → `STALE` (veraltet, wird bei nächster Nutzung neu geprüft) → `FAILED` (nicht erreichbar)
- [ ] Standard-Timeout: ~15-30 Minuten bis ein Eintrag `STALE` wird
- [ ] **Gratuitous ARP**: ein Host sendet ungefragt seine eigene IP-MAC-Zuordnung — damit alle Geräte im Netz ihren Cache sofort aktualisieren
- [ ] ARP funktioniert nur **innerhalb eines Subnetzes** — über Subnetzgrenzen hinweg braucht man den Gateway

## Flashcards

**Q:** Warum zeigt `ip route show` nicht alle Routen?
**A:** Es zeigt nur die `main`-Tabelle. `ip route show table local` zeigt die `local`-Tabelle (eigene IPs), `ip route show table all` zeigt alles. Linux hat intern drei Tabellen: `local`, `main`, `default`.

**Q:** Was bedeutet `scope link` in einer Route?
**A:** Das Ziel ist direkt erreichbar (im selben LAN-Segment), kein Gateway nötig. Der Kernel hat diese Route automatisch angelegt, weil eine IP auf dem Interface konfiguriert ist.

**Q:** Was ist Gratuitous ARP und wozu dient es?
**A:** Ein Host sendet ungefragt ein ARP-Paket mit seiner eigenen IP-MAC-Zuordnung ins Netz. Alle Geräte aktualisieren sofort ihren ARP-Cache. Wird bei IP-Failover genutzt (z.B. MetalLB L2-Mode, VRRP), damit Traffic sofort zum neuen Host geht, statt auf den ARP-Timeout zu warten.

**Q:** Wann wird ein ARP-Eintrag `STALE`?
**A:** Nach ca. 15-30 Minuten ohne Bestätigung. Bei nächster Nutzung geht der Eintrag in `DELAY` → `PROBE` (Kernel sendet ARP-Request). Kommt eine Antwort → `REACHABLE`. Kommt keine → `FAILED`.

## Lab: Routing und ARP im Detail (30 Min)

Alle Commands in der Multipass-VM (`multipass shell rz-node`):

### 1. Alle Routing-Tabellen anzeigen

```bash
# Standard-Tabelle (main)
ip route show

# Lokale Tabelle — hier stehen deine eigenen IPs als Routen
ip route show table local

# Alle Tabellen auf einmal
ip route show table all

# Welche Regel bestimmt welche Tabelle?
ip rule show
```

**Dokumentiere:**
- [ ] Wie viele Einträge hat die `local`-Tabelle?
- [ ] Was fällt dir auf, wenn du deine VM-IP in der `local`-Tabelle siehst?
- [ ] Was sagen die `ip rule`-Einträge aus?

### 2. Route zu einem Ziel abfragen

```bash
# Welche Route wird für ein bestimmtes Ziel verwendet?
ip route get 8.8.8.8
ip route get 10.0.0.1

# Vergleiche: lokales vs. entferntes Ziel
ip route get 127.0.0.1
```

**Dokumentiere:**
- [ ] Welches Interface und welchen Gateway nennt `ip route get 8.8.8.8`?
- [ ] Was ist anders bei `ip route get 127.0.0.1`?

### 3. ARP-Cache beobachten

```bash
# Aktuellen ARP-Cache anzeigen
ip neigh show

# Cache leeren (erfordert sudo) und beobachten wie er sich neu aufbaut
sudo ip neigh flush all
ip neigh show

# Jetzt einen Ping machen und den Cache erneut prüfen
ping -c 1 $(ip route show default | awk '{print $3}')
ip neigh show
```

**Dokumentiere:**
- [ ] Was steht im Cache vor und nach dem Flush?
- [ ] Welchen Zustand hat der Gateway-Eintrag nach dem Ping? (`REACHABLE`?)
- [ ] Warte 2-3 Minuten und prüfe erneut — hat sich der Zustand geändert?

### 4. ARP-Auflösung live beobachten

```bash
# tcpdump auf ARP-Pakete filtern (in einem zweiten Terminal)
sudo tcpdump -i eth0 arp -n

# In einem anderen Terminal: ARP-Cache leeren und Ping machen
sudo ip neigh flush all
ping -c 1 8.8.8.8
```

**Dokumentiere:**
- [ ] Welche ARP-Pakete siehst du? (Request und Reply)
- [ ] Wer fragt nach wem? (Quell-IP → Ziel-IP)

## Profi-Wissen für den RZ-Alltag

### ARP-Probleme im Kubernetes-Cluster

Im RZ mit MetalLB im L2-Mode ist ARP-Verhalten kritisch:

```
Szenario: Node-Failover
─────────────────────────
1. Node-A hat die LoadBalancer-IP 10.0.1.100 → MAC aa:bb:cc:dd:ee:01
2. Node-A fällt aus
3. Node-B übernimmt 10.0.1.100 → MAC aa:bb:cc:dd:ee:02
4. Problem: alle Switches/Router im Netz haben noch den alten ARP-Eintrag!
5. Lösung: Node-B sendet Gratuitous ARP → alle aktualisieren sofort
```

Ohne Gratuitous ARP müsstest du bis zu 15 Minuten warten, bis der alte ARP-Eintrag abläuft. In der Zwischenzeit geht Traffic an die alte MAC → ins Leere.

**Debugging-Befehl:** `ip neigh show | grep 10.0.1.100` — zeigt dir ob die richtige MAC hinterlegt ist.

### Asymmetrisches Routing erkennen

Wenn Pakete auf einem anderen Weg zurückkommen als sie hingegangen sind:

```bash
# Hinweg prüfen
traceroute 10.0.5.42

# Rückweg prüfen (auf dem Zielserver)
traceroute <deine-IP>
```

Wenn die Pfade unterschiedlich sind → **asymmetrisches Routing**. Das kann Firewalls verwirren (Stateful Inspection sieht nur eine Richtung) und ist eine häufige Ursache für "Verbindung geht manchmal, manchmal nicht."

### MTU-Probleme finden

Das häufigste "unsichtbare" Problem im RZ:

```bash
# MTU des Interfaces prüfen
ip link show eth0 | grep mtu

# Testen ob große Pakete durchkommen (Don't Fragment Flag setzen)
ping -M do -s 1472 -c 1 8.8.8.8    # 1472 + 28 Byte Header = 1500 (Ethernet MTU)
ping -M do -s 1473 -c 1 8.8.8.8    # 1 Byte zu viel → sollte fehlschlagen

# Bei VXLAN/Cilium: MTU muss reduziert werden (50 Byte VXLAN-Header)
# Normale MTU: 1500 → mit VXLAN: 1450
```

**Symptom bei MTU-Problemen:** Kleine Pakete (Ping, DNS) funktionieren, große Pakete (HTTP-Downloads, SSH-Copy) hängen oder brechen ab. Der Klassiker: "Ping geht, aber SCP bleibt stecken."

### Die drei häufigsten Routing-Fehler im RZ

| Nr. | Fehler | Symptom | Fix |
|-----|--------|---------|-----|
| 1 | **Fehlende Default Route** | "Network is unreachable" für alles außer lokales Netz | `ip route add default via <gateway>` |
| 2 | **Falsches Gateway** | Pakete gehen raus, aber Antworten kommen nicht zurück | `ip route show default` prüfen, Gateway muss im selben Subnetz sein |
| 3 | **Source IP stimmt nicht** | Server antwortet mit falscher Absender-IP (bei mehreren Interfaces) | `ip route get <ziel>` zeigt welche Source-IP verwendet wird |

## Mini-Quiz

1. Was ist der Unterschied zwischen `ip route show` und `ip route show table all`?
2. Ein ARP-Eintrag hat den Zustand `STALE`. Was bedeutet das und was passiert beim nächsten Paket an diese IP?
3. Warum sendet MetalLB einen Gratuitous ARP bei einem Failover?
4. `ping -s 1472 8.8.8.8` funktioniert, `ping -s 1473 8.8.8.8` nicht. Erkläre warum.

## Reflexion

- [ ] Kann ich die drei Routing-Tabellen erklären?
- [ ] Verstehe ich die ARP-Zustandsmaschine (REACHABLE → STALE → PROBE)?
- [ ] Kann ich MTU-Probleme mit `ping -M do` testen?
- [ ] Weiß ich warum Gratuitous ARP bei Failover-Szenarien wichtig ist?
