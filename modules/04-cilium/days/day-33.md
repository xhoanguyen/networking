# Tag 33 — Ch4: IPAM Part 2

**Modul:** 04 — Cilium: Up and Running  
**Buch:** Ch4 — IP Address Management  
**Ziel:** Multi-Pool IPAM verstehen und konfigurieren, ENI und Dual-Stack konzeptuell kennen

---

## Flashcard-Recap

- **AWS ENI IPAM**: Delegation an AWS EC2 API — Cilium kommuniziert direkt mit AWS, IPs sind physisch an ENIs gebunden
- **Multi-Pool IPAM**: Mehrere `CiliumPodIPPool` CRDs, Zuweisung via Node-Labels oder Namespace-Annotations
- **Dual-Stack**: IPv4 + IPv6 gleichzeitig — Kubernetes muss dual-stack enabled sein (≥ v1.20) bevor Cilium mitmacht
- **maskSize**: Granularität der Block-Zuteilung pro Node — Node kann dynamisch mehrere Blöcke bekommen

---

## Lab-Aufgaben

### Aufgabe 1 — Cluster aufsetzen

Erstelle einen Kind-Cluster und installiere Cilium im `multi-pool` IPAM-Modus.

Warum muss das Cluster neu erstellt werden — kann man von `cluster-pool` auf `multi-pool` upgraden?

---

### Aufgabe 2 — Multi-Pool IPAM verifizieren

Wie bestätigst du dass `multi-pool` aktiv ist?

Welcher Befehl zeigt dir die zugeteilten IP-Blöcke pro Node, und was bedeutet `requested.needed`?

---

### Aufgabe 3 — Tenant-Pools erstellen

Erstelle zwei separate `CiliumPodIPPool` Objekte für zwei Tenants:
- `acme-pool`: `10.20.0.0/16`, maskSize 27
- `foobar-pool`: `10.30.0.0/16`, maskSize 27

Wie viele Pod-IPs kann ein Node maximal gleichzeitig aus einem einzelnen /27-Block bekommen?

---

### Aufgabe 4 — Namespace-Zuweisung

Erstelle zwei Namespaces `acme-corp` und `foobar-inc`.

Welche Annotation muss gesetzt werden damit Pods im Namespace aus dem richtigen Pool ihre IP bekommen?

---

### Aufgabe 5 — Pool-Zuweisung beweisen

Starte je einen Pod in `acme-corp` und `foobar-inc`.

Beweise mit `kubectl get pod -o wide` dass die IPs aus den richtigen Pools kommen.

Welcher Befehl zeigt dir anschließend dass die Nodes neue Blöcke aus den Tenant-Pools bekommen haben?
