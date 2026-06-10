# Flashcards — Ch3: Cilium Basics (Tag 31)

Vor dem Lab durchgehen: Frage lesen, Antwort laut formulieren, dann aufklappen.

---

**Q:** Was ist der erste Befehl bei Cilium-Problemen und was zeigt er?

<details><summary>Antwort</summary>

`cilium status` — zeigt Agent, Operator, Hubble und Endpoint-Anzahl.

</details>

---

**Q:** Was ist ein Cilium-Endpoint und was bedeutet `ready` vs. `not-ready`?

<details><summary>Antwort</summary>

Endpoint = ein Pod (+ System-Endpoints wie Host, Health). `ready` = eBPF-Programme geladen, Identity berechnet, Policy aktiv. `not-ready` = Cilium verarbeitet noch — Policy greift noch nicht. Ein Pod kann K8s `Running` sein, aber der Endpoint noch `not-ready`.

</details>

---

**Q:** Worüber erzwingt Cilium Network Policies — IP oder Identity? Warum ist das wichtig?

<details><summary>Antwort</summary>

Über die **Identity** (numerische ID aus allen Labels: Custom + System + Namespace). Dadurch bleibt das Enforcement stabil bei Pod-Neustarts mit neuer IP.

</details>

---

**Q:** Zwei Pods haben identische Custom-Labels, laufen aber in unterschiedlichen Namespaces. Gleiche Identity?

<details><summary>Antwort</summary>

Nein — der Namespace fließt als Label in die Identity ein → **unterschiedliche Identities**.

</details>

---

**Q:** Was bewirkt der `endpointSelector` in einer CiliumNetworkPolicy?

<details><summary>Antwort</summary>

Er definiert die **Perspektive**: auf welche Endpoints die Policy zutrifft. Von dort aus werden Ingress/Egress-Regeln definiert. Sobald eine `ingress`-Regel existiert → automatischer Ingress Default-Deny.

</details>

---

**Q:** Ein Request läuft in einen Timeout, ein anderer bekommt Connection Refused. Welcher deutet auf einen Policy-Drop hin?

<details><summary>Antwort</summary>

Der **Timeout** — eBPF droppt das Paket, es kommt kein TCP RST. Connection Refused heißt: Host erreichbar, Port/App-Problem — kein Policy-Problem.

</details>

---

**Q:** Was zeigt Hubble — rohe Pakete oder etwas anderes?

<details><summary>Antwort</summary>

**Flow-Events**, nicht rohe Pakete: Pod-Namen, Policy-Entscheidung, L7-Infos. `hubble observe --follow` parallel beim Testen laufen lassen.

</details>

---

**Q:** Unterschied zwischen `cilium-dbg` und `cilium`?

<details><summary>Antwort</summary>

`cilium-dbg` = Binary **im Agent-Pod** (ab v1.14). `cilium` = externes CLI-Tool auf der Workstation.

</details>
