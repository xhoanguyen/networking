# CCA Exam Notes

Lernnotizen für die Cilium Certified Associate (CCA) Prüfung.
Wird nach jedem abgeschlossenen Tag ergänzt.

---

## Ch3 — Cilium Basics (Tag 31)

### Health Check
- Erster Befehl bei Problemen: `cilium status` — zeigt Agent, Operator, Hubble, Endpoint-Anzahl

### Endpoints
- Endpoint = ein Pod (+ System-Endpoints wie Host, Health)
- `ready` = eBPF-Programme geladen, Identity berechnet, Policy aktiv
- `not-ready` = Cilium verarbeitet noch — Policy greift noch nicht
- Ein Pod kann K8s `Running` sein aber Cilium-Endpoint noch `not-ready`

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list
kubectl exec -n kube-system ds/cilium -- cilium-dbg endpoint list -o json
```

> `cilium-dbg` = Binary im Agent-Pod (ab v1.14). `cilium` = externes CLI-Tool.

### Identity
- Identity = numerische ID, berechnet aus **allen** Labels (Custom + System + Namespace)
- Pods mit identischen Custom-Labels aber unterschiedlichen Namespaces → **unterschiedliche Identities**
- Policy-Enforcement läuft über Identity, nicht über IP → stabil bei Pod-Neustart

```bash
kubectl exec -n kube-system ds/cilium -- cilium-dbg identity get <ID>
```

### CiliumNetworkPolicy
- `endpointSelector` = Perspektive (auf wen die Policy zutrifft)
- Von dort aus wird Ingress/Egress definiert
- Sobald eine `ingress`-Regel existiert → automatischer Ingress Default-Deny

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

### Traffic-Verhalten bei Policy-Drop
- Geblockte Pakete → **Timeout** (eBPF drop, kein TCP RST)
- Connection Refused → Host erreichbar, Port/App-Problem (kein Policy-Problem)

### Hubble
- Zeigt **Flow-Events** (nicht rohe Pakete): Pod-Namen, Policy-Entscheidung, L7-Infos
- `hubble observe --follow` — parallel beim Testen laufen lassen

---

## Ch4 — IPAM Part 1 (Tag 32)

### Grundlagen
- Pod-IP-Vergabe = Aufgabe des **CNI-Plugins** (nicht kube-proxy)
- kube-proxy = Service-Routing (iptables/ipvs)
- Ablauf: Pod startet → kubelet ruft CNI auf → CNI fragt IPAM → Pod bekommt IP

### IPAM-Modi

| Modus | Verwaltung | Speicherort | Geeignet für |
|-------|-----------|-------------|--------------|
| `kubernetes` | K8s verwaltet podCIDR | `spec.podCIDR` am Node-Objekt | Kleine Cluster, einfache Setups, CNI-Migration |
| `cluster-scope` | Cilium Operator verwaltet zentralen Pool | `CiliumNode` CRD (eines pro Node) | Große Cluster, IP-Effizienz |

### kubernetes-Modus (host-scope)
- K8s weist jedem Node einen festen CIDR-Block zu (z.B. `10.0.1.0/24`)
- Cilium liest `spec.podCIDR` und vergibt IPs daraus
- Vorab-Reservierung des gesamten Blocks — auch wenn nur wenige Pods laufen

```bash
kubectl get node <node-name> -o jsonpath='{.spec.podCIDR}'
```

### cluster-scope
- Cilium Operator verwaltet den gesamten Cluster-CIDR zentral
- IPs werden **on-demand** vergeben — kein vorab reservierter Block pro Node
- Speicherort: `CiliumNode` Custom Resources

```bash
kubectl get ciliumnodes
kubectl get ciliumnode <node-name> -o yaml
```

> Für RKE2 + Cilium: cluster-scope ist der empfohlene Default.
