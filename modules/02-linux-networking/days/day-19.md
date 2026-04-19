# Tag 19 — Alles zusammen: Container-Netzwerk von Null aufbauen

## What are we doing today and why?

Du hast Namespaces, veth pairs, Bridges und NAT einzeln gelernt. Heute baust du alles in einem Durchgang zusammen — ohne Vorlage, ohne Schritt-für-Schritt-Anleitung. Das Ergebnis ist ein vollständiges Container-Netzwerk: isolierte Netzwerk-Kontexte, L2-Switch im Kernel, Internet-Zugang via NAT. Exakt das was Docker mit `docker0` macht — nur dass du es selbst baust.

**Warum:** In der Praxis bekommst du keine Anleitung. Du bekommst ein Problem. Heute übst du den kompletten Ablauf aus dem Kopf — das ist der Unterschied zwischen "ich hab es mal gemacht" und "ich verstehe es wirklich".

## Lesen (10 Min)

Heute kein neues Material. Stattdessen: schau dir deine eigenen Notizen und die Solution-Files von Tag 16, 17 und 18 an — aber erst wenn du nicht weiterkommst.

## Kernkonzepte (Wiederholung)

- [ ] Network Namespace = isolierter Netzwerk-Kontext
- [ ] veth pair = virtuelles Kabel zwischen zwei Kontexten
- [ ] Linux Bridge = virtueller L2-Switch
- [ ] IP Forwarding = Kernel leitet Pakete weiter (nicht nur für sich selbst)
- [ ] MASQUERADE = private IPs hinter Host-IP verstecken
- [ ] conntrack = macht NAT stateful

## Lab: Container-Netzwerk komplett aufbauen

Alle Commands in der Multipass-VM (`multipass shell rz-node`). Starte mit einer sauberen VM — lösche alle alten Namespaces und Bridges falls vorhanden.

**Ziel:** Dieses Setup komplett selbst aufbauen:

```
ns1 (10.1.0.2/24)      ns2 (10.1.0.3/24)
       │                        │
   veth-ns1                 veth-ns2
       │                        │
   veth-ns1-br             veth-ns2-br
       │                        │
       └─────── br0 (10.1.0.1/24) ───────┘
                      │
                   enp0s1
                      │
                  Internet
```

**Anforderungen:**
- ns1 und ns2 können sich gegenseitig pingen
- ns1 und ns2 können die Bridge pingen (Gateway)
- ns1 und ns2 können `8.8.8.8` pingen

---

### Aufgabe 1 — Sauberer Start

Prüfe den Ausgangszustand: keine alten Namespaces, keine alte Bridge. Wie prüfst du das? Wie räumst du auf?

---

### Aufgabe 2 — Namespaces erstellen

Erstelle `ns1` und `ns2`. Verifiziere.

---

### Aufgabe 3 — Bridge aufbauen

Erstelle `br0` mit IP `10.1.0.1/24`. Bringe sie UP. Verifiziere.

---

### Aufgabe 4 — veth pairs erstellen und verbinden

Erstelle zwei veth pairs. Bridge-Enden an `br0` enslaven. Alle Interfaces UP.

Danach: verifiziere mit `bridge link show`.

---

### Aufgabe 5 — Namespaces konfigurieren

Verschiebe die Namespace-Enden in `ns1` und `ns2`. Vergib IPs. Bringe Interfaces UP. Setze Default Routes.

Danach: verifiziere mit `ip netns exec ns1 ip addr show` und `ip netns exec ns1 ip route show`.

---

### Aufgabe 6 — L2 testen

```bash
sudo ip netns exec ns1 ping -c 3 10.1.0.3
```

Funktioniert? Erkläre was auf L2 passiert.

---

### Aufgabe 7 — Internet-Zugang herstellen

Aktiviere IP Forwarding. Konfiguriere MASQUERADE. Teste:

```bash
sudo ip netns exec ns1 ping -c 3 8.8.8.8
```

Wenn es nicht sofort funktioniert — debugge systematisch. Welche drei Dinge musst du prüfen?

---

### Aufgabe 8 — Alles verifizieren

Führe diese Checks durch und erkläre jeden Output:

```bash
bridge link show
bridge fdb show br br0
sudo iptables -t nat -L -v -n
sudo conntrack -L
sudo ip netns exec ns1 ip route show
```

---

### Aufräumen

Lösche alles: Namespaces, Bridge, NAT-Regeln. Verifiziere dass der Ausgangszustand wiederhergestellt ist.

## Mini-Quiz (Theorie — RZ Kontext)

1. **Docker startet einen Container.** Welche der heutigen Schritte führt Docker intern automatisch aus?

2. **Ein Entwickler sagt: "Mein Container kann nicht ins Internet."** Was sind deine ersten drei Debugging-Schritte?

3. **Zwei Pods auf demselben Kubernetes-Node sollen kommunizieren.** Auf welcher Schicht passiert das — und warum?

4. **Du siehst in `conntrack -L` einen Eintrag mit State `ESTABLISHED`.** Was bedeutet das für die Firewall-Regeln?

## Reflexion

- [ ] Ich kann das vollständige Setup aus dem Kopf aufbauen — ohne Vorlage
- [ ] Ich kann jeden Schritt erklären warum er nötig ist
- [ ] Ich kann systematisch debuggen wenn etwas nicht funktioniert
- [ ] Ich erkenne den Zusammenhang zu Docker und Kubernetes
- [ ] Ich kann das Setup sauber aufräumen

## Faustregeln

**Reihenfolge beim Aufbau:**
1. Namespaces erstellen
2. Bridge erstellen + IP + UP
3. veth pairs erstellen + enslaven + UP
4. Namespace-Enden verschieben + IP + UP + Default Route
5. IP Forwarding aktivieren
6. MASQUERADE konfigurieren

**Debugging-Reihenfolge wenn Internet nicht geht:**
1. `ip route show` im Namespace — Default Route da?
2. `cat /proc/sys/net/ipv4/ip_forward` — Forwarding aktiv?
3. `iptables -t nat -L -v -n` — MASQUERADE-Regel da?
4. `tcpdump -i enp0s1` — kommt das Paket überhaupt raus?

**Merksatz:** *Namespace + veth + Bridge + Forwarding + NAT = Docker. Du hast Docker gerade selbst gebaut.*
