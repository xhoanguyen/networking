# Tag 31 — Ch3: Cilium Basics (Lösung)

## Aufgabe 1 — Cluster-Check

```bash
cilium status
```

Zeigt: Agent-Health, Operator-Status, Endpoint-Anzahl, Hubble-Status.

---

## Aufgabe 2 — Endpoints inspizieren

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list
```

Mit JSON-Output:
```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list -o json
```

**ready** = eBPF-Programme geladen, Identity berechnet, Policy aktiv → Traffic wird korrekt enforced  
**not-ready** = Cilium verarbeitet den Endpoint noch → Policy greift noch nicht

Wichtig: Ein Pod kann in Kubernetes `Running` sein, aber Cilium-Endpoint noch `not-ready`. Erster Check bei "Pod läuft aber kein Netz".

---

## Aufgabe 3 — Identity verstehen

`pod-a` (`app=frontend`) und `pod-b` (`app=backend`) haben **unterschiedliche Identities** — Cilium berechnet die Identity aus **allen** Labels inklusive Kubernetes-System-Labels (Namespace, Cluster).

Identity einer Pod nachschauen:
```bash
# Endpoint-Liste mit Identity-ID
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list

# Details zur Identity
kubectl exec -n kube-system ds/cilium -- cilium-dbg identity get <ID>
```

Zwei Pods mit `app=frontend` in unterschiedlichen Namespaces haben **unterschiedliche Identities** — Namespace geht mit in die Berechnung.

---

## Aufgabe 4 — Erste CiliumNetworkPolicy

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: default
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: frontend
```

**endpointSelector** = auf wen die Policy zutrifft (Perspektive: ich bin `backend`)  
**fromEndpoints** = wer darf rein (nur `frontend`)  

Sobald eine `ingress`-Regel definiert ist → automatischer Ingress Default-Deny für alles andere.

Mentaler Trick: Erst fragen "wessen Perspektive?" — dann Ingress/Egress festlegen.

---

## Aufgabe 5 — Policy testen

```bash
# Von pod-a (app=frontend) auf pod-b (app=backend) → erlaubt
kubectl exec -it pod-a -- curl <pod-b-IP>

# Von einem Pod mit app=other → Timeout (nicht Connection Refused!)
```

**Timeout** = Cilium droppt das Paket still (eBPF drop, kein TCP RST)  
**Connection Refused** = Host erreichbar, aber Port/App-Problem

Unterschied ist entscheidend beim Troubleshooting:
- Timeout → Policy oder Routing-Problem
- Connection Refused → App-Problem

---

## Bonus — Hubble CLI

```bash
hubble observe --follow
```

Hubble zeigt **verarbeitete Flow-Events** (nicht rohe Pakete):
- Source/Destination als Pod-Name + Namespace
- Policy-Entscheidung (allow/drop + welche Policy)
- L7-Infos bei Proxy (HTTP-Method, URL, Status-Code)

tcpdump → rohe Pakete, nur IPs  
Hubble → strukturierter Kontext, direkt mit Pod-Namen

Im RZ: `hubble observe` parallel beim Testen laufen lassen — siehst sofort ob Traffic geblockt wird, ohne auf Timeout zu warten.
