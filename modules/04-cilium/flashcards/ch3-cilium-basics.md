# Flashcards — Ch3: Cilium Basics (Tag 31)

Vor dem Lab durchgehen: Frage lesen, Antwort laut formulieren, dann aufklappen.

---

**Q:** Was ist der erste Befehl bei Cilium-Problemen und was zeigt er?

<details><summary>Antwort</summary>

`cilium status` — zeigt Agent, Operator, Hubble und Endpoint-Anzahl.

**Quelle:** [Component Overview](https://docs.cilium.io/en/stable/overview/component-overview/)

</details>

---

**Q:** Was ist ein Cilium-Endpoint und was bedeutet `ready` vs. `not-ready`?

<details><summary>Antwort</summary>

Endpoint = ein Pod (+ System-Endpoints wie Host, Health). `ready` = eBPF-Programme geladen, Identity berechnet, Policy aktiv. `not-ready` = Cilium verarbeitet noch — Policy greift noch nicht. Ein Pod kann K8s `Running` sein, aber der Endpoint noch `not-ready`.

**Quelle:** [Endpoint Lifecycle](https://docs.cilium.io/en/stable/security/policy/lifecycle/) — States: `waiting-for-identity` → `waiting-to-regenerate` → `regenerating` → `ready`.

</details>

---

**Q:** Worüber erzwingt Cilium Network Policies — IP oder Identity? Warum ist das wichtig?

<details><summary>Antwort</summary>

Über die **Identity** (numerische ID aus allen Labels: Custom + System + Namespace). Dadurch bleibt das Enforcement stabil bei Pod-Neustarts mit neuer IP.

**Quelle:** [Terminology — Identity](https://docs.cilium.io/en/stable/gettingstarted/terminology/) — "all endpoints which share the same set of Security Relevant Labels will share the same identity."

</details>

---

**Q:** Zwei Pods haben identische Custom-Labels, laufen aber in unterschiedlichen Namespaces. Gleiche Identity?

<details><summary>Antwort</summary>

Nein — der Namespace fließt als Label in die Identity ein → **unterschiedliche Identities**.

**Quelle:** [Limiting Identity-Relevant Labels](https://docs.cilium.io/en/stable/operations/performance/scalability/identity-relevant-labels/) — der Namespace-Label ist standardmäßig identitäts-relevant (nicht in der Exclude-Liste).

</details>

---

**Q:** Was bewirkt der `endpointSelector` in einer CiliumNetworkPolicy?

<details><summary>Antwort</summary>

Er definiert die **Perspektive**: auf welche Endpoints die Policy zutrifft. Von dort aus werden Ingress/Egress-Regeln definiert. Sobald eine `ingress`-Regel existiert → automatischer Ingress Default-Deny.

**Quelle:** [Layer 3 Policies](https://docs.cilium.io/en/stable/security/policy/layer3/) / [Policy Enforcement Modes](https://docs.cilium.io/en/stable/security/policy/intro/) — "If any rule selects an Endpoint and the rule has an ingress section, the endpoint goes into default deny at ingress."

</details>

---

**Q:** Ein Request läuft in einen Timeout, ein anderer bekommt Connection Refused. Welcher deutet auf einen Policy-Drop hin?

<details><summary>Antwort</summary>

Der **Timeout** — eBPF droppt das Paket, es kommt kein TCP RST. Connection Refused heißt: Host erreichbar, Port/App-Problem — kein Policy-Problem.

**Quelle:** [Policy Enforcement Modes](https://docs.cilium.io/en/stable/security/policy/intro/) — Whitelist-Modell, nicht-erlaubter Traffic wird **gedroppt** (kein RST → Timeout). *Hinweis:* dass "Connection Refused = RST = App-Problem" gilt, ist **TCP-Semantik**, kein wörtlicher Cilium-Doku-Satz.

</details>

---

**Q:** Was zeigt Hubble — rohe Pakete oder etwas anderes?

<details><summary>Antwort</summary>

**Flow-Events**, nicht rohe Pakete: Pod-Namen, Policy-Entscheidung, L7-Infos. `hubble observe --follow` parallel beim Testen laufen lassen.

**Quelle:** [Network Observability with Hubble](https://docs.cilium.io/en/stable/observability/hubble/) / [Intro to Cilium & Hubble](https://docs.cilium.io/en/stable/overview/intro/) — "transparent" = ohne Code-Änderung, nicht "jedes Byte". Rohpakete = `tcpdump` / `cilium-dbg monitor`.

</details>

---

**Q:** Unterschied zwischen `cilium-dbg` und `cilium`?

<details><summary>Antwort</summary>

`cilium-dbg` = Binary **im Agent-Pod** (ab v1.14). `cilium` = externes CLI-Tool auf der Workstation.

**Quelle:** [Component Overview](https://docs.cilium.io/en/stable/overview/component-overview/) — "cilium-dbg … interacts with the REST API of the Cilium agent running on the same node … direct access to the eBPF maps." *Hinweis:* Die Doku belegt die **Tool-Trennung** (per-Node, in-Pod vs. extern), **nicht** die Versionsnummer "ab v1.14" — die habe ich nicht doku-belegt.

</details>
