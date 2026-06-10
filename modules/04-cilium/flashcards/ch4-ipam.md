# Flashcards — Ch4: IPAM (Tag 32–33)

Vor dem Lab durchgehen: Frage lesen, Antwort laut formulieren, dann aufklappen.

---

**Q:** Wer vergibt Pod-IPs — kube-proxy oder das CNI-Plugin? Was macht der jeweils andere?

<details><summary>Antwort</summary>

Das **CNI-Plugin** (mit seinem IPAM). kube-proxy macht Service-Routing (iptables/ipvs). Ablauf: Pod startet → kubelet ruft CNI auf → CNI fragt IPAM → Pod bekommt IP.

</details>

---

**Q:** IPAM-Modus `kubernetes` vs. `cluster-scope` — wer verwaltet, wo gespeichert?

<details><summary>Antwort</summary>

| Modus | Verwaltung | Speicherort |
|-------|-----------|-------------|
| `kubernetes` | K8s weist jedem Node einen festen podCIDR zu | `spec.podCIDR` am Node-Objekt |
| `cluster-scope` | Cilium Operator verwaltet zentralen Pool | `CiliumNode` CRD (eines pro Node) |

`kubernetes` = kleine Cluster, CNI-Migration. `cluster-scope` = große Cluster, IP-Effizienz — und der empfohlene Default für RKE2 + Cilium.

</details>

---

**Q:** Kann man den IPAM-Modus eines laufenden Clusters wechseln (z.B. cluster-pool → multi-pool)?

<details><summary>Antwort</summary>

Nein — IPAM ist eine **Day-0-Entscheidung**. Ein Wechsel verliert alle Pod-IPs, das Cluster muss neu aufgebaut werden.

</details>

---

**Q:** Wie weist man bei Multi-Pool IPAM einem Namespace einen bestimmten Pool zu?

<details><summary>Antwort</summary>

Mit der Annotation `ipam.cilium.io/ip-pool: <pool-name>` auf dem Namespace. Cilium liest sie beim Pod-Start und wählt den entsprechenden `CiliumPodIPPool`.

</details>

---

**Q:** Was bestimmt `maskSize` in einem CiliumPodIPPool — und ist es ein Hard-Limit pro Node?

<details><summary>Antwort</summary>

Die Granularität der Block-Zuteilung pro Node (z.B. /27 = 32 Adressen). **Kein Hard-Limit**: Ist ein Block voll, bekommt der Node dynamisch einen weiteren Block zugeteilt.

</details>

---

**Q:** Kann ein Node gleichzeitig Blöcke aus mehreren Pools halten?

<details><summary>Antwort</summary>

Ja — z.B. `default` + `acme-pool`, je nachdem welche Pods auf ihm laufen. Sichtbar in `spec.ipam.pools` der `CiliumNode` CR.

</details>

---

**Q:** Mit welchen Befehlen prüfst du Multi-Pool IPAM (Pools + Blöcke pro Node)?

<details><summary>Antwort</summary>

```bash
kubectl get ciliumpodippools
kubectl get ciliumnodes -o json | jq '.items[] | {node: .metadata.name, pools: .spec.ipam.pools}'
```

`requested.needed` = wie viele Adressen der Node aktuell anfordert.

</details>

---

**Q:** AWS ENI IPAM — was macht Cilium da anders? (Konzept reicht)

<details><summary>Antwort</summary>

Cilium delegiert die IP-Verwaltung an die **EC2 API** — IPs sind physisch an ENIs gebunden. Exam-relevant, im on-prem RZ nicht.

</details>

---

**Q:** Was sind die Voraussetzungen für Dual-Stack mit Cilium? (Konzept reicht)

<details><summary>Antwort</summary>

Kubernetes selbst muss dual-stack enabled sein (≥ v1.20), dazu `ipv6.enabled: true` in Cilium (in Kind: `ipFamily: dual`). Exam-relevant, im RZ ohne IPv6 nicht.

</details>
