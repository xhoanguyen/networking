# Cilium Troubleshooting-Playbook

Für die tägliche Arbeit im RZ (RKE2 + Cilium). Wächst mit jedem echten Fall —
jeder Eintrag folgt dem Schema **Symptom → Diagnose-Kette → Root Cause → Fix → Verifikation**.

---

## Die Grundschleife

Bei jedem Cilium-Problem in dieser Reihenfolge — nie eine Stufe überspringen:

1. **Symptom erfassen:** `cilium status` (Agent, Operator, Endpoints, Warnings/Errors)
2. **Logs filtern:** `kubectl -n kube-system logs ds/cilium --since=10m | grep -E "level=(warn|error)"`
3. **Dem Fehler nach unten folgen:** Der erste sichtbare Fehler ist oft Folgesymptom.
   Frage: *Was muss vorher passiert sein, damit dieser Fehler entsteht?*
4. **Root Cause benennen** — erst dann fixen
5. **Verifizieren:** `cilium status --wait` + den konkreten Symptom-Check wiederholen

**Faustregeln:**
- Identische `warn`-Meldung im festen Takt (`retryDelay=Xs`) = Retry-Loop auf ein
  **Umgebungsproblem** (Kernel, Berechtigungen, fehlendes Device) — kein Versions-Bump hilft
- Pod kann K8s `Running` sein, aber Cilium-Endpoint `not-ready` — immer beide Ebenen prüfen

---

## Fall 1 — Endpoints not-ready, Datapath-Init scheitert (Tunnel-Device)

**Datum:** 2026-06-11 (Tag 34, kind auf Docker Desktop / Mac M1)

**Symptom:**
- `cilium status`: alle Endpoints `not-ready`, `cilium-health-ep` Timeouts
- Logs: BPF-Compile-Fehler (`ENABLE_ARP_RESPONDER macro redefined`, `-Werror`)

**Falsche Fährte:** Die Compile-Fehler sahen nach Cilium-Bug aus (GitHub #38222).
Drei Versionen probiert (1.18.2 → 1.18.10 → 1.19.4) — dreimal identischer Fehler.

**Echte Root Cause** (tiefer im Log, alle 10s wiederholt):

```
Failed to initialize datapath, retrying later
  error="... creating device cilium_geneve: invalid argument"
```

Der Kernel (Docker-Desktop-VM) kann kein GENEVE-Device anlegen.
Kette: Device-Erstellung scheitert → Datapath-Init scheitert → runtime-`node_config.h`
wird nie gerendert → BPF-Compile fällt auf statische Fallback-Header → Macro-Konflikt.
Die Compile-Fehler waren **Folgesymptom**, nicht Ursache.

**Fix:** `tunnelProtocol: vxlan` statt `geneve` (Konzept identisch: Overlay, ipcache,
keine via-Routen). Im RZ stattdessen: Kernel-Module prüfen, bevor man Cilium verdächtigt:

```bash
uname -r
lsmod | grep -E "geneve|vxlan"   # bzw. modprobe geneve testen
```

---

## Fall 2 — Config geändert, Verhalten unverändert

**Datum:** 2026-06-11 (Tag 34)

**Symptom:** Nach `helm upgrade` (tunnelProtocol geneve → vxlan) weiterhin GENEVE-Fehler
in den Logs.

**Diagnose:**

```bash
kubectl -n kube-system get pods -l k8s-app=cilium -o wide   # Pod-AGE prüfen!
kubectl -n kube-system get cm cilium-config -o jsonpath='{.data.tunnel-protocol}'
```

Pod-Age **älter** als die Config-Änderung → der Agent hat die neue Config nie gesehen.
Cilium loggt es sogar explizit:

```
msg="Mismatch found" module=...config-drift-checker key=tunnel-protocol actual=geneve expectedValue=vxlan
```

**Root Cause:** `helm upgrade` ändert nur die ConfigMap — das Pod-Template bleibt gleich,
der DaemonSet-Controller rollt nichts neu. Der Agent liest seine Config nur beim Start.

**Fix:**

```bash
kubectl -n kube-system rollout restart ds/cilium
cilium status --wait
```

**RZ-Transfer:** Auf RKE2 mit `HelmChartConfig` exakt dasselbe Muster — nach jeder
Cilium-Config-Änderung prüfen, ob die Agent-Pods tatsächlich neu gestartet sind
(Pod-Age vs. Änderungszeitpunkt).
