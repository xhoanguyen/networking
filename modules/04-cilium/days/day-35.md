# Tag 35 — Ch6: kube-proxy Replacement Part 1

**Modul:** 04 — Cilium: Up and Running
**Buch:** Ch6 — kube-proxy Replacement
**Ziel:** Verstehen, *wer* das Service-Load-Balancing macht — und Cilium ohne kube-proxy fahren und live beweisen, dass kein kube-proxy mehr im Spiel ist.

---

## Flashcard-Recap

Vorher durchgehen: `flashcards/ch3-cilium-basics.md` + `flashcards/ch4-ipam.md`

Heutige Kernkonzepte (mündlich wiederholen, bevor du tippst):
- **Control Plane vs. Data Plane** bei kube-proxy: Wer schreibt die Regeln, wer führt sie aus?
- **iptables-Skalierungsproblem:** Warum ist O(n) + Full-Reload bei Updates der Killer?
- **Socket-LB vs. tc/XDP:** Welcher Hook greift wann? Die *eine* richtige Entscheidungsfrage?
- **east-west vs. north-south:** Welche Achse ist welche?

---

## Lab-Aufgaben

> Stack: kind auf dem Mac (Docker Desktop), Cilium 1.19.4. Wie an Tag 34.

### Aufgabe 1 — Ist-Zustand: läuft kube-proxy noch?

Dein bestehendes Cluster (chapter05, Tunnel/VXLAN) wurde mit dem kind-Default gebaut —
also **mit** kube-proxy.

1. Mit welchem `kubectl`-Befehl prüfst du, ob ein kube-proxy-DaemonSet im `kube-system`-Namespace läuft?
2. Bevor du es ausführst: Wie viele kube-proxy-Pods erwartest du bei einem Cluster mit
   1 Control-Plane + 2 Workern — und **warum genau diese Zahl**?
3. Was meldet `cilium status` aktuell in der Zeile `KubeProxyReplacement`? Was bedeutet der Wert?

---

### Aufgabe 2 — Cluster ohne kube-proxy neu bauen

Um kube-proxy *wirklich* zu ersetzen, muss das Cluster **ohne** kube-proxy gebaut werden —
sonst würden sich beide um die Service-Regeln streiten.

1. Welcher Schlüssel in der **kind-Config** verhindert, dass kind überhaupt einen kube-proxy ausrollt?
   (Tipp: unter `networking:`)
2. Baue das Cluster damit neu auf und installiere Cilium mit aktiviertem kube-proxy-Replacement.
   Welcher **Helm-Value** schaltet das Replacement an?
3. Welche zwei Dinge muss Cilium jetzt zusätzlich wissen, die ihm sonst kube-proxy bzw. das
   `default`-Gateway abgenommen hätte? (Tipp: Wie erreicht der Cilium-Agent den **API-Server**,
   wenn es kein kube-proxy gibt, das die `kubernetes`-ClusterIP übersetzt?)

Falls etwas klemmt: Grundschleife aus dem
[Troubleshooting-Playbook](../cheatsheets/troubleshooting-playbook.md) abarbeiten.

---

### Aufgabe 3 — Beweisen, dass kein kube-proxy mehr da ist (3 Ebenen)

Ein einzelner Check reicht nicht. Beweise es auf drei Ebenen:

1. **Workload-Ebene:** Welcher Befehl zeigt, dass es **kein** kube-proxy-DaemonSet mehr gibt?
2. **Kernel-Ebene:** Führe auf einem Node `iptables-save | grep -c KUBE-SVC` aus.
   Welche Zahl *musst* du sehen, wenn kube-proxy weg ist — und was wären diese `KUBE-SVC`-Ketten
   gewesen, wenn kube-proxy noch liefe?
3. **Cilium-Ebene:** Was meldet `cilium status` in der `KubeProxyReplacement`-Zeile jetzt?
   Welche Devices listet es dahinter auf, und warum gerade die?

---

### Aufgabe 4 — ClusterIP-Service anlegen und in der eBPF-Map finden

1. Deploye eine simple App (z.B. 2 Replicas) und exponiere sie als `ClusterIP`-Service.
2. Finde den Service in der eBPF-Service-Map:
   ```bash
   kubectl -n kube-system exec ds/cilium -- cilium-dbg service list
   ```
   - Was ist die **Frontend**-Adresse, was sind die **Backends**?
   - Wie viele Backend-Einträge erwartest du bei 2 Replicas — und stimmt es?
3. Skaliere das Deployment auf 4 Replicas. Was passiert in der Service-Map — und **wer** hat sie
   aktualisiert (welche Komponente, Control Plane oder Data Plane)?

---

### Aufgabe 5 — Hook-Vorhersage: Socket-LB oder tc/XDP?

Sag für **jedes** Szenario voraus, welcher Hook die ClusterIP/NodePort übersetzt — und begründe
mit der *einen* richtigen Frage ("Wo wird `connect()` aufgerufen?"):

| # | Szenario | Hook? | Warum? |
|---|----------|-------|--------|
| a | Pod auf Node-1 → ClusterIP, Backend auf Node-1 | ? | ? |
| b | Pod auf Node-1 → ClusterIP, Backend auf Node-2 | ? | ? |
| c | Externer Laptop → NodePort, Backend auf demselben Node | ? | ? |
| d | Externer Laptop → NodePort, Backend auf anderem Node | ? | ? |

Bonus — verifiziere, dass Socket-LB aktiv ist:
```bash
kubectl -n kube-system exec ds/cilium -- cilium-dbg status --verbose
```
Suche im `KubeProxyReplacement Details`-Block die Zeile `Socket LB`. Was steht da — und warum ist
das die richtige Quelle, und **nicht** `cilium config view | grep -i sock`?
