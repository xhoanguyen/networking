# Tag 32 — Ch4: IPAM Part 1 (Lösung)

## Aufgabe 1 — Cluster aufsetzen

```bash
kind create cluster --name cilium-lab --config /Users/xhoa/workspace/cilium-up-and-running/chapter04/kind.yaml
cilium install --helm-values /Users/xhoa/workspace/cilium-up-and-running/chapter04/cilium-ipam-cluster-scope.yaml
cilium status --wait
```

`disableDefaultCNI: true` — ohne diesen Flag installiert Kind automatisch **kindnet** als CNI. Dann laufen zwei CNIs parallel und Cilium kann das Netzwerk nicht übernehmen.

---

## Aufgabe 2 — IPAM-Modus verifizieren

```bash
# Option 1
cilium config view | grep ipam

# Option 2
kubectl get configmap cilium-config -n kube-system -o yaml | grep ipam
```

Ausgabe in cluster-pool mode:
```
ipam    cluster-pool
```

`cluster-pool` ist der interne Helm-Wert — in der Doku heißt es "cluster-scope", im Chart heißt es `cluster-pool`.

---

## Aufgabe 3 — Node CIDRs inspizieren

```bash
kubectl get ciliumnodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.ipam.podCIDRs}{"\n"}{end}'
```

Beispiel-Ausgabe:
```
cilium-lab-control-plane    ["10.0.0.0/24"]
cilium-lab-worker           ["10.0.1.0/24"]
cilium-lab-worker2          ["10.0.2.0/24"]
```

CIDRs werden vom **Cilium Operator** aus dem zentralen Pool zugeteilt.

---

## Aufgabe 4 — Den Unterschied beweisen

| Befehl | kubernetes-mode | cluster-pool mode |
|--------|----------------|-------------------|
| `kubectl get nodes .spec.podCIDR` | `10.244.x.0/24` | `10.244.x.0/24` |
| `kubectl get ciliumnodes .spec.ipam.podCIDRs` | `10.244.x.0/24` | `10.0.x.0/24` |

In **kubernetes-mode**: beide CIDRs identisch — Cilium übernimmt was Kubernetes vorgibt.  
In **cluster-pool mode**: CIDRs weichen ab — Cilium Operator verwendet seinen eigenen Pool. Das `.spec.podCIDR` auf dem Node-Objekt gilt nicht für Pods.

Wichtig: In Kind setzt kube-controller-manager `.spec.podCIDR` immer — auch in cluster-pool mode. Der Unterschied ist sichtbar wenn man beide Ranges vergleicht.

---

## Aufgabe 5 — Pod-IP verifizieren

```bash
kubectl run pod-test --image=nginx
kubectl get pod pod-test -o wide
```

In cluster-pool mode kommt die IP aus dem **Cilium-CIDR** (`10.0.x.0/24`), nicht aus dem Kubernetes-CIDR (`10.244.x.0/24`).

Das ist der finale Beweis: Pods ignorieren `.spec.podCIDR` auf dem Node und bekommen ihre IP vom Cilium Operator.

---

## Key Takeaways

- IPAM-Mode ist eine Day-0-Entscheidung — nachträglicher Wechsel ist destruktiv (alle Pod-IPs ändern sich)
- In cluster-pool mode ist `kubectl get nodes` die falsche Stelle für IP-Ranges — immer `kubectl get ciliumnodes` verwenden
- `cilium config view | grep ipam` ist der schnellste Check für den aktiven Modus
- Timeout beim Pod-Connect → Policy oder Routing-Problem. Connection Refused → App-Problem
