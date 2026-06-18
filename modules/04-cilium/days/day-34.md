# Tag 34 — Ch5: Routing (Native Routing, Tunnel-Modus, Node-Routes)

**Modul:** 04 — Cilium: Up and Running  
**Buch:** Ch5 — Routing  
**Ziel:** Die zwei Routing-Modi verstehen und live vergleichen — wo liegt die Routing-Intelligenz jeweils?

---

## Flashcard-Recap

Vorher durchgehen: `flashcards/ch3-cilium-basics.md` + `flashcards/ch4-ipam.md`

---

## Lab-Aufgaben

### Aufgabe 1 — Aktuellen Routing-Modus bestimmen

Welcher Routing-Modus läuft auf dem bestehenden Cluster (chapter04-Setup)?

Mit welchem Befehl prüfst du das — und warum ist das Ergebnis hier nicht der Cilium-Default?

---

### Aufgabe 2 — Routen vorhersagen (Native Routing)

Bevor du `ip route` ausführst: Wie viele Routen zu Pod-CIDRs erwartest du auf `cilium-lab-worker`?

Leite die Zahl aus den `CiliumNode` CRs her (`spec.ipam.pools` der **anderen** Nodes).

Verifiziere mit `docker exec -it cilium-lab-worker ip route` und ordne jede Zeile einer Kategorie zu:
Default / Pod-CIDR-Route / lokale Routen.

Worauf zeigen die via-Routen — und über welches Device gehen sie raus?

---

### Aufgabe 3 — Cluster auf Tunnel-Modus umbauen

Baue das Cluster neu auf (chapter05 kind-Config) und installiere Cilium im Tunnel-Modus mit GENEVE.

Falls etwas schiefgeht: Arbeite die Grundschleife aus dem
[Troubleshooting-Playbook](../cheatsheets/troubleshooting-playbook.md) ab —
nicht beim ersten Fehler stehenbleiben.

---

### Aufgabe 4 — Tunnel-Modus verifizieren (3 Ebenen)

Beweise mit drei Checks, dass der Tunnel-Modus aktiv ist:

1. Config: Welche zwei Schlüssel prüfst du in `cilium config view`?
2. Routing-Tabelle: Wie sehen die Routen auf dem Worker jetzt aus — worauf zeigen die via-Routen,
   und was ist der fundamentale Unterschied zu Aufgabe 2?
3. Devices: Welches neue Device muss existieren — und woran erkennst du in `ip link`,
   dass es **kein** veth-Pair ist?

---

### Aufgabe 5 — ipcache lesen

Wenn die Kernel-Routing-Tabelle im Tunnel-Modus "dumm" ist — wo liegt die Routing-Intelligenz?

```bash
kubectl -n kube-system exec ds/cilium -- cilium-dbg bpf ipcache list
```

1. Welche zwei Informationen liefert die Map pro Pod-IP (Key → Value)?
2. Was bedeutet `flags=hastunnel` vs. `tunnelendpoint=0.0.0.0`?
3. Bonus: Auf welchem Node läuft der Agent, dessen ipcache du siehst — ohne `kubectl get pods`?
