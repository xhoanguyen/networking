# Tag 33 — Ch4: IPAM Part 2 (Lösung)

## Aufgabe 1 — Cluster aufsetzen

```bash
kind delete cluster --name cilium-lab
kind create cluster --name cilium-lab \
  --config /Users/xhoa/workspace/cilium-up-and-running/chapter04/kind.yaml

helm install cilium cilium/cilium --version 1.18.2 \
  --namespace kube-system \
  -f /Users/xhoa/workspace/cilium-up-and-running/chapter04/cilium-ipam-multi-pool.yaml

cilium status --wait
```

IPAM ist eine Day-0-Entscheidung — ein Wechsel von `cluster-pool` auf `multi-pool` ist nicht möglich ohne alle Pod-IPs zu verlieren. Neues Cluster ist Pflicht.

---

## Aufgabe 2 — Multi-Pool IPAM verifizieren

```bash
kubectl get configmap -n kube-system cilium-config -o yaml | grep ipam
```

Ausgabe:
```
ipam: multi-pool
```

Blöcke pro Node anzeigen:
```bash
kubectl get ciliumnodes -o json | jq '.items[] | {node: .metadata.name, pools: .spec.ipam.pools}'
```

`requested.needed` zeigt wie viele Adressen der Node aktuell anfordert — Cilium teilt dynamisch weitere /27-Blöcke zu wenn der aktuelle Block voll ist.

---

## Aufgabe 3 — Tenant-Pools erstellen

```bash
kubectl apply -f /Users/xhoa/workspace/cilium-up-and-running/chapter04/acme-pool.yaml
kubectl apply -f /Users/xhoa/workspace/cilium-up-and-running/chapter04/foobar-pool.yaml
kubectl get ciliumpodippools
```

Ein `/27`-Block hat 32 Adressen (2⁵ = 32) — ein Node kann also bis zu 32 Pods aus einem Block bedienen. Wenn mehr Pods kommen, bekommt der Node automatisch einen weiteren `/27`-Block zugeteilt.

---

## Aufgabe 4 — Namespace-Zuweisung

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: acme-corp
  annotations:
    ipam.cilium.io/ip-pool: acme-pool
---
apiVersion: v1
kind: Namespace
metadata:
  name: foobar-inc
  annotations:
    ipam.cilium.io/ip-pool: foobar-pool
```

```bash
kubectl apply -f /Users/xhoa/workspace/cilium-up-and-running/chapter04/namespaces.yaml
```

Die Annotation `ipam.cilium.io/ip-pool` ist der Mechanismus — Cilium liest sie beim Pod-Start und wählt den entsprechenden Pool.

---

## Aufgabe 5 — Pool-Zuweisung beweisen

```bash
kubectl run test-acme --image=nginx -n acme-corp
kubectl run test-foobar --image=nginx -n foobar-inc

kubectl get pod test-acme -n acme-corp -o wide
kubectl get pod test-foobar -n foobar-inc -o wide
```

Erwartete Ausgabe:
- `test-acme` → IP aus `10.20.0.0/16` (acme-pool)
- `test-foobar` → IP aus `10.30.0.0/16` (foobar-pool)

Node-Blöcke prüfen:
```bash
kubectl get ciliumnodes -o json | jq '.items[] | {node: .metadata.name, pools: .spec.ipam.pools}'
```

Nodes haben jetzt mehrere Pools gleichzeitig: `default` + `acme-pool` oder `foobar-pool` — je nachdem welcher Pod wo läuft.

---

## Key Takeaways

- Multi-Pool IPAM = mehrere `CiliumPodIPPool` CRDs, Zuweisung via `ipam.cilium.io/ip-pool` Annotation auf Namespace
- `maskSize` bestimmt die Block-Granularität pro Node — kein Hard-Limit, weitere Blöcke werden dynamisch zugeteilt
- Nodes können gleichzeitig Blöcke aus mehreren Pools halten
- AWS ENI IPAM: nur für AWS — Cilium delegiert IP-Verwaltung an EC2 API (für CCA relevant, im RZ nicht)
- Dual-Stack: `ipFamily: dual` in Kind + `ipv6.enabled: true` in Cilium — Kubernetes muss dual-stack enabled sein (für CCA relevant, im RZ ohne IPv6 nicht)
- `kubectl wait --for=condition=Ready pod --all -n <namespace> --timeout=120s` — gezieltes Warten statt `sleep`
