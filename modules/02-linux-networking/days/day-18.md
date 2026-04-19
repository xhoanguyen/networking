# Tag 18 — NAT: Namespaces ins Internet bringen

## What are we doing today and why?

Gestern hast du verstanden wie iptables Pakete filtert. Heute lösen wir das eigentliche Problem: deine Namespaces haben private IPs (`10.0.0.x`) — das Internet kennt diese Adressen nicht. Damit Pakete trotzdem ankommen, muss der Host die Absender-IP ersetzen. Das ist **Network Address Translation (NAT)** — und es ist der Mechanismus hinter jedem Home-Router, jedem Docker-Container und jedem Kubernetes-Pod der ins Internet kommuniziert.

**Warum:** NAT ist allgegenwärtig im RZ. Load Balancer, Service Meshes, Container-Runtimes — alle nutzen NAT. Wer NAT nicht versteht, kann keine Connectivity-Probleme debuggen wenn Pakete auf mysteriöse Weise verschwinden.

## Lesen (20 Min)

**Pflicht:**
- `man iptables-extensions` — Abschnitte MASQUERADE, SNAT, DNAT
- **LARTC Kapitel 11** — NAT: Network Address Translation

**Optional:**
- **"Linux Firewalls"** — Kapitel NAT und Connection Tracking
- **"Linux Network Administrator's Guide"** — IP Masquerading

## Kernkonzepte

- [ ] **IP Forwarding** muss im Kernel aktiviert sein — sonst leitet der Host keine Pakete weiter
- [ ] **MASQUERADE** — dynamisches SNAT: Absender-IP wird durch die aktuelle Host-IP ersetzt (für DHCP-Interfaces)
- [ ] **SNAT** — statisches Source NAT: Absender-IP wird durch eine feste IP ersetzt (für statische IPs)
- [ ] **DNAT** — Destination NAT: Ziel-IP wird ersetzt — das ist Port Forwarding
- [ ] NAT greift in der `nat`-Tabelle, nicht in `filter`
- [ ] **conntrack** macht NAT stateful — Antwortpakete werden automatisch zurückübersetzt
- [ ] MASQUERADE sitzt in der `POSTROUTING`-Chain — nach der Routing-Entscheidung

## Flashcards

**Q:** Was ist der Unterschied zwischen MASQUERADE und SNAT?
**A:** MASQUERADE ersetzt die Absender-IP dynamisch mit der aktuellen IP des ausgehenden Interfaces — gut für DHCP. SNAT verwendet eine fest konfigurierte IP — effizienter weil kein Interface-Lookup nötig. Im RZ mit statischen IPs: immer SNAT bevorzugen.

**Q:** Warum reicht eine MASQUERADE-Regel für alle Namespaces?
**A:** conntrack verfolgt jede Verbindung bidirektional. Wenn ein Paket von `10.0.0.2` nach außen geht, merkt sich conntrack die Übersetzung. Das Antwortpaket wird automatisch zurückübersetzt — ohne extra Regel.

**Q:** Was ist DNAT und wo wird es verwendet?
**A:** DNAT ersetzt die Ziel-IP (und optional den Port) eines eingehenden Pakets. Damit lässt sich Port Forwarding realisieren — z.B. externer Port 8080 → interner Service auf 10.0.0.2:80. Kubernetes `NodePort` und `LoadBalancer` Services nutzen genau das.

**Q:** In welcher Chain sitzt MASQUERADE, und warum?
**A:** In `POSTROUTING` — nach der Routing-Entscheidung. Erst wenn der Kernel weiß welches Interface das Paket verlässt, kann er die richtige IP eintragen.

## Lab: NAT konfigurieren

Alle Commands in der Multipass-VM (`multipass shell rz-node`).

**Voraussetzung:** Bridge `br0` mit `10.0.0.1/24`, Namespaces `ns1`/`ns2`/`ns3` mit IPs aus Tag 16. Falls die VM neugestartet wurde: alles ist weg — baue es kurz wieder auf (Lösung in `day-16_SOLUTION.md`).

**Ziel heute:** ns1 soll `8.8.8.8` pingen können.

```
ns1 (10.0.0.2)
    │
veth-ns1 → br0 (10.0.0.1)
    │
    Host (enp0s1, externe IP)
    │  ← MASQUERADE ersetzt 10.0.0.2 mit Host-IP
    │
Internet (8.8.8.8)
```

---

### Aufgabe 1 — IP Forwarding aktivieren

Bevor du NAT konfigurierst: Prüfe ob IP Forwarding aktiv ist. Wie aktivierst du es — temporär und dauerhaft?

Was passiert mit Paketen von ns1 ins Internet wenn IP Forwarding deaktiviert ist?

---

### Aufgabe 2 — Default Route in den Namespaces

ns1 hat eine Connected Route für `10.0.0.0/24` — aber keine Default Route. Was fehlt damit Pakete an `8.8.8.8` überhaupt losgeschickt werden?

Zeige die Routing-Tabelle in ns1 und füge die fehlende Route hinzu.

---

### Aufgabe 3 — MASQUERADE konfigurieren

Jetzt die eigentliche NAT-Regel. Denk nach:
- Welche Tabelle brauchst du?
- Welche Chain?
- Welches Interface verlässt das Paket den Host?

---

### Aufgabe 4 — Ping ins Internet testen

```bash
sudo ip netns exec ns1 ping -c 3 8.8.8.8
```

Funktioniert es? Wenn nicht — was fehlt noch? Debugge Schritt für Schritt:
1. Kommt das Paket überhaupt bei der Bridge an?
2. Leitet der Host es weiter?
3. Greift MASQUERADE?

---

### Aufgabe 5 — NAT-Tabelle beobachten

Während du pingst:

```bash
sudo iptables -t nat -L -v -n
sudo conntrack -L
```

Was siehst du? Erkläre was `pkts` und `bytes` bei der MASQUERADE-Regel bedeuten.

---

### Bonus — DNAT: Port Forwarding

Starte einen einfachen HTTP-Server in ns1:

```bash
sudo ip netns exec ns1 python3 -m http.server 80
```

Konfiguriere DNAT so dass Port 8080 auf dem Host an `10.0.0.2:80` weitergeleitet wird. Teste mit `curl localhost:8080` vom Host.

## Mini-Quiz (Theorie)

1. **Ein Paket von ns1 (10.0.0.2) geht zu 8.8.8.8.** Welche Felder im IP-Header werden durch MASQUERADE verändert?

2. **Das Antwortpaket von 8.8.8.8 kommt beim Host an — Ziel-IP ist die Host-IP.** Wie weiß der Host dass es für ns1 bestimmt ist?

3. **In Kubernetes hat jeder Pod eine eigene IP.** Warum brauchen Pods trotzdem NAT wenn sie ins Internet wollen?

## Reflexion

- [ ] Ich kann IP Forwarding aktivieren und verstehe warum es nötig ist
- [ ] Ich kann MASQUERADE konfigurieren und weiß in welcher Chain/Tabelle es sitzt
- [ ] Ich kann eine Default Route in einem Namespace setzen
- [ ] Ich verstehe wie conntrack NAT stateful macht
- [ ] Ich kann DNAT für Port Forwarding konfigurieren

## Faustregeln

**NAT:**
- MASQUERADE in `nat` Tabelle, `POSTROUTING` Chain
- DNAT in `nat` Tabelle, `PREROUTING` Chain
- IP Forwarding vergessen = häufigster NAT-Fehler

**Debugging NAT:**
- `iptables -t nat -L -v -n` → NAT-Regeln mit Countern
- `conntrack -L` → aktive NAT-Übersetzungen
- `tcpdump -i br0` → sieht man die Original-IPs
- `tcpdump -i enp0s1` → sieht man die übersetzten IPs

**Merksatz:** *MASQUERADE ist wie ein Briefkasten — alle Briefe aus dem Namespace gehen unter der Adresse des Hosts raus. Die Antworten kommen zurück und conntrack weiß wem sie gehören.*
