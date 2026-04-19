# Tag 20 — Final Exam: Linux Networking

Kein Lesen heute. Kein Spicken in Solution-Files. Du bekommst Theorie-Fragen und ein Lab — beides aus dem Kopf.

---

## Teil 1 — Theorie (RZ Kontext)

Beantworte diese Fragen schriftlich oder im Gespräch. Keine Recherche — was weißt du?

### Block A — Konzepte

1. Was ist ein Network Namespace und wie unterscheidet er sich von einer Firewall-Regel als Isolationsmechanismus?

2. Erkläre den Unterschied zwischen einem veth pair und einer Linux Bridge. Wann brauchst du was?

3. Was ist MAC-Learning und warum ist es wichtig für die Performance einer Bridge?

4. Ein Kollege fragt: "Warum hat `docker0` eine IP-Adresse — Bridges sind doch Layer-2-Geräte?" Wie antwortest du?

5. Was ist Unknown Unicast Flooding und wann tritt es auf?

### Block B — Befehle

6. Welcher Befehl zeigt dir alle Interfaces die an einer Bridge hängen — mit State?

7. Wie prüfst du die MAC-Adress-Tabelle einer Bridge?

8. Du hast `ip link set veth-ns1 netns ns1` ausgeführt. Wie verifizierst du dass es funktioniert hat?

9. Welcher Befehl zeigt dir alle aktiven NAT-Übersetzungen?

10. Du verdächtigst dass eine iptables-Regel greift aber nicht sicher — wie findest du es heraus ohne Traffic zu generieren?

### Block C — Debugging

11. Ein Namespace kann die Bridge pingen aber nicht `8.8.8.8`. Was sind deine ersten drei Checks?

12. `bridge link show` zeigt `state disabled` auf einem Port — was könnte die Ursache sein?

13. Du siehst `NO-CARRIER` auf einem veth Interface. Was bedeutet das und wie behebst du es?

14. Ein Ping von ns1 nach ns2 funktioniert nicht obwohl beide an derselben Bridge hängen und IPs haben. Nenne drei mögliche Ursachen.

### Block D — RZ Praxis

15. Du nimmst an einem Incident teil. Ein Kollege sagt: "Der Pod kann andere Pods auf demselben Node pingen aber nicht ins Internet." Welche Layer und Komponenten musst du prüfen?

16. Was ist der Unterschied zwischen MASQUERADE und SNAT — und wann nimmst du was im RZ?

17. Ein Entwickler fragt: "Warum bekommt mein Container eine `172.17.x.x` IP?" Erkläre was Docker intern macht.

18. Was ist Gratuitous ARP und wann wird es im RZ eingesetzt?

---

## Teil 2 — Lab (60 Min)

Baue folgendes Setup komplett neu auf — ohne Solution-Files zu öffnen.

### Topologie

```
ns-web (10.2.0.10/24)    ns-db (10.2.0.20/24)    ns-cache (10.2.0.30/24)
         │                        │                        │
     veth-web               veth-db                 veth-cache
         │                        │                        │
     veth-web-br            veth-db-br              veth-cache-br
         │                        │                        │
         └──────────── br-internal (10.2.0.1/24) ──────────┘
                                  │
                               enp0s1
                                  │
                              Internet
```

### Anforderungen

**Pflicht:**
- [ ] Drei Namespaces: `ns-web`, `ns-db`, `ns-cache`
- [ ] Bridge `br-internal` mit IP `10.2.0.1/24`
- [ ] Drei veth pairs mit sinnvollen Namen
- [ ] Alle Namespaces können sich gegenseitig pingen
- [ ] Alle Namespaces können die Bridge pingen
- [ ] `ns-web` kann `8.8.8.8` pingen
- [ ] `ns-db` kann `8.8.8.8` pingen
- [ ] `ns-cache` kann `8.8.8.8` pingen

**Bonus:**
- [ ] Starte `python3 -m http.server 8000` in `ns-web` und erreicheentsprechende Port Forwarding vom Host via DNAT
- [ ] Zeige die Bridge FDB nach einem Ping-Test und erkläre jeden Eintrag

### Verifikation

Führe am Ende diese Checks durch und erkläre jeden Output:

```bash
ip netns list
bridge link show
bridge fdb show br br-internal
sudo iptables -t nat -L -v -n
sudo ip netns exec ns-web ip route show
sudo ip netns exec ns-web ping -c 2 8.8.8.8
sudo ip netns exec ns-web ping -c 2 10.2.0.20
sudo ip netns exec ns-db ping -c 2 10.2.0.30
```

### Aufräumen

Lösche alles vollständig. Verifiziere den sauberen Ausgangszustand.

---

## Auswertung

**Theorie:**
- 15–18 richtig → solides Fundament, bereit für Modul 3
- 10–14 richtig → Kernkonzepte sitzen, Details nochmal anschauen
- unter 10 → Tag 16–19 nochmal wiederholen

**Lab:**
- Alle Pflichtanforderungen ohne Hilfe → sehr gut
- Mit 1-2 Nachschlägen → gut
- Bonus geschafft → ausgezeichnet

---

## Was kommt in Modul 3?

Du hast jetzt das Fundament: Namespaces, veth, Bridge, iptables, NAT. Modul 3 baut darauf auf:

- **BGP und dynamisches Routing** — wie Pakete im Internet ihren Weg finden
- **VXLAN und Overlay-Netzwerke** — wie Kubernetes Pods über Nodes hinweg verbindet
- **WireGuard** — modernes VPN auf Kernel-Ebene
- **Network Policies** — Kubernetes-Firewall für Pod-Traffic
