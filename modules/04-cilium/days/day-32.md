# Tag 32 — Ch4: IPAM Part 1

**Modul:** 04 — Cilium: Up and Running  
**Buch:** Ch4 — IP Address Management  
**Ziel:** IPAM-Modi in der Praxis vergleichen — cluster-pool vs. kubernetes

---

## Flashcard-Recap

- **kubernetes-mode**: kube-controller-manager teilt CIDRs zu, Cilium liest sie vom Node-Objekt
- **cluster-pool mode** (Default): Cilium Operator teilt CIDRs aus eigenem Pool zu, unabhängig von Kubernetes
- **Helm-Wert**: `cluster-pool` ist der interne Name für cluster-scope
- **Multi-Pool**: verschiedene Pools für verschiedene Node-Gruppen (IPAM Part 2)

---

## Lab-Aufgaben

### Aufgabe 1 — Cluster aufsetzen

Erstelle einen Kind-Cluster mit Cilium im cluster-pool Modus.

Welche Config-Datei brauchst du, und warum muss `disableDefaultCNI: true` gesetzt sein?

---

### Aufgabe 2 — IPAM-Modus verifizieren

Wie bestätigst du welcher IPAM-Modus aktiv ist — ohne in die values.yaml zu schauen?

Zwei Wege sind möglich — welche?

---

### Aufgabe 3 — Node CIDRs inspizieren

Welcher Befehl zeigt dir die Pod-CIDRs der einzelnen Nodes in cluster-pool mode?

Schreib den jsonpath-Befehl für CiliumNodes.

---

### Aufgabe 4 — Den Unterschied beweisen

Wechsle auf kubernetes-mode (neuer Cluster nötig).

Führe diese zwei Befehle auf beiden Modi aus und vergleiche:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.podCIDR}{"\n"}{end}'
kubectl get ciliumnodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.ipam.podCIDRs}{"\n"}{end}'
```

Was ist der Unterschied in der Ausgabe?

---

### Aufgabe 5 — Pod-IP verifizieren

Starte einen Pod und beweise mit `kubectl get pod -o wide` aus welchem CIDR die IP kommt.

In cluster-pool mode: kommt die IP aus dem Kubernetes-CIDR oder dem Cilium-CIDR?
