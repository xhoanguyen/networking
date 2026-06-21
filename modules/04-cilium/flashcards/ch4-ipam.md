# Flashcards — Ch4: IPAM (Tag 32–33)

Vor dem Lab durchgehen: Frage lesen, Antwort laut formulieren, dann aufklappen.

---

**Q:** Wer vergibt Pod-IPs — kube-proxy oder das CNI-Plugin? Was macht der jeweils andere?

<details><summary>Antwort</summary>

Das **CNI-Plugin** (mit seinem IPAM). kube-proxy macht Service-Routing (iptables/ipvs). Ablauf: Pod startet → kubelet ruft CNI auf → CNI fragt IPAM → Pod bekommt IP.

**Quelle:** [IP Address Management (IPAM)](https://docs.cilium.io/en/stable/network/concepts/ipam/) — IPAM = Pod-IP-Vergabe (CNI), getrennt vom Service-Load-Balancing.

</details>

---

**Q:** IPAM-Modus `kubernetes` vs. `cluster-scope` — wer verwaltet, wo gespeichert?

<details><summary>Antwort</summary>

| Modus | Verwaltung | Speicherort |
|-------|-----------|-------------|
| `kubernetes` | K8s weist jedem Node einen festen podCIDR zu | `spec.podCIDR` am Node-Objekt |
| `cluster-scope` | Cilium Operator verwaltet zentralen Pool | `CiliumNode` CRD (eines pro Node) |

`kubernetes` = kleine Cluster, CNI-Migration. `cluster-scope` = große Cluster, IP-Effizienz — und der empfohlene Default für RKE2 + Cilium.

**Quelle:** [IPAM Concepts](https://docs.cilium.io/en/stable/network/concepts/ipam/) / [Kubernetes Host Scope](https://docs.cilium.io/en/stable/network/concepts/ipam/kubernetes/) — `kubernetes`-Modus liest `spec.podCIDR` vom v1.Node.

</details>

---

**Q:** Kann man den IPAM-Modus eines laufenden Clusters wechseln (z.B. cluster-pool → multi-pool)?

<details><summary>Antwort</summary>

Nein — IPAM ist eine **Day-0-Entscheidung**. Ein Wechsel verliert alle Pod-IPs, das Cluster muss neu aufgebaut werden.

**Quelle:** [IPAM Concepts](https://docs.cilium.io/en/stable/network/concepts/ipam/) — "Changing the IPAM mode in a live environment may cause persistent disruption of connectivity for existing workloads. The safest path … is to install a fresh Kubernetes cluster with the new IPAM configuration."

</details>

---

**Q:** Wie weist man bei Multi-Pool IPAM einem Namespace einen bestimmten Pool zu?

<details><summary>Antwort</summary>

Mit der Annotation `ipam.cilium.io/ip-pool: <pool-name>` auf dem Namespace. Cilium liest sie beim Pod-Start und wählt den entsprechenden `CiliumPodIPPool`.

**Quelle:** [Multi-Pool IPAM](https://docs.cilium.io/en/stable/network/concepts/ipam/multi-pool/) — "either on the pod or the namespace of the pod"; nur beim Pod-**Create** wirksam. **Annotation, kein Label** (Label = identitäts-relevant, würde Policies beeinflussen).

</details>

---

**Q:** Was bestimmt `maskSize` in einem CiliumPodIPPool — und ist es ein Hard-Limit pro Node?

<details><summary>Antwort</summary>

Die Granularität der Block-Zuteilung pro Node (z.B. /27 = 32 Adressen). **Kein Hard-Limit**: Ist ein Block voll, bekommt der Node dynamisch einen weiteren Block zugeteilt.

**Quelle:** [Multi-Pool IPAM](https://docs.cilium.io/en/stable/network/concepts/ipam/multi-pool/) — `maskSize` = Schnittgröße pro Node-Block aus dem Pool-CIDR; `preAllocIPs`-Watermark hält Puffer vor, damit Pod-Scheduling nicht auf den Operator wartet.

</details>

---

**Q:** Kann ein Node gleichzeitig Blöcke aus mehreren Pools halten?

<details><summary>Antwort</summary>

Ja — z.B. `default` + `acme-pool`, je nachdem welche Pods auf ihm laufen. Sichtbar in `spec.ipam.pools` der `CiliumNode` CR.

**Quelle:** [Multi-Pool IPAM](https://docs.cilium.io/en/stable/network/concepts/ipam/multi-pool/) — "List of CIDRs allocated to a node **and the pool they were allocated from**" (`spec.ipam.pools.allocated` ist eine Liste). Pod → genau 1 Pool, Node → ggf. viele.

</details>

---

**Q:** Mit welchen Befehlen prüfst du Multi-Pool IPAM (Pools + Blöcke pro Node)?

<details><summary>Antwort</summary>

```bash
kubectl get ciliumpodippools
kubectl get ciliumnodes -o json | jq '.items[] | {node: .metadata.name, pools: .spec.ipam.pools}'
```

`requested.needed` = wie viele Adressen der Node aktuell anfordert.

**Quelle:** [Multi-Pool IPAM](https://docs.cilium.io/en/stable/network/concepts/ipam/multi-pool/) — `CiliumPodIPPool` = Pool-**Definition** (cluster-weit, "welche Pools gibt es?"); `CiliumNode` = **Zuteilung** pro Node ("was hält *dieser* Node?"). Nicht vertauschen.

</details>

---

**Q:** AWS ENI IPAM — was macht Cilium da anders? (Konzept reicht)

<details><summary>Antwort</summary>

Cilium delegiert die IP-Verwaltung an die **EC2 API** — IPs sind physisch an ENIs gebunden. Exam-relevant, im on-prem RZ nicht.

**Quelle:** [AWS ENI](https://docs.cilium.io/en/stable/network/concepts/ipam/eni/) — "performs IP allocation based on IPs of AWS Elastic Network Interfaces (ENI) by communicating with the AWS EC2 API." Pod-IPs = native VPC-IPs, kein Overlay. (ENI kann **kein** IPv6.)

</details>

---

**Q:** Was sind die Voraussetzungen für Dual-Stack mit Cilium? (Konzept reicht)

<details><summary>Antwort</summary>

Kubernetes selbst muss dual-stack enabled sein (≥ v1.20), dazu `ipv6.enabled: true` in Cilium (in Kind: `ipFamily: dual`). Exam-relevant, im RZ ohne IPv6 nicht.

**Quelle:** [Kubernetes — IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/) — Prereqs: "Kubernetes 1.20 or later" + "A network plugin that supports dual-stack networking." Cilium-Seite: `ipv6.enabled` / Agent-Flag `enable-ipv6` ([cilium-agent flags](https://docs.cilium.io/en/stable/cmdref/cilium-agent/)).

</details>
