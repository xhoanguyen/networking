# Tag 28 — eBPF Fundamentals: Architektur, Maps, Programme

## Lernziel

eBPF ist die Technologie hinter Cilium, modernen Firewalls und Observability-Tools.
Du verstehst heute wie eBPF im Kernel funktioniert — Konzepte, Inspektion mit bpftool, und dein erstes eigenes XDP-Programm.

---

## Flashcards — erst durchgehen, dann Lab

**1. Was bedeutet eBPF?**

Extended Berkeley Packet Filter. BPF kam ursprünglich aus BSD für Packet Filtering, eBPF erweitert das Konzept auf den gesamten Kernel.

**2. Was macht eBPF in einem Satz?**

eBPF erlaubt es, eigene Programme sicher im Linux-Kernel auszuführen — ohne den Kernel neu zu kompilieren oder das System neu zu starten.

**3. Was ist der Verifier?**

Die Sicherheitsschleuse des Kernels. Er prüft jeden Bytecode bevor er ausgeführt wird:
- Keine ungültigen Speicherzugriffe
- Kein Endlosloop (Programm muss immer terminieren)
- Ausreichende Rechte

**4. Warum ist XDP_DROP schneller als iptables DROP?**

XDP läuft bevor der Kernel einen `sk_buff` (Socket-Buffer) anlegt. Kein Speicher allozieren, kein iptables-Regelwerk durchlaufen — das Paket wird direkt am NIC-Treiber verworfen.

**5. Was sind eBPF Maps?**

Key-Value-Speicher im Kernel — geteilter Speicher zwischen Kernel (eBPF-Programm) und Userspace (z.B. Cilium Agent). Kernel schreibt Paket-Statistiken, Userspace schreibt Policy-Entscheidungen.

**6. Welche drei XDP Actions gibt es?**

- `XDP_DROP` — Paket sofort verwerfen
- `XDP_PASS` — Paket normal an Kernel-Stack weitergeben
- `XDP_TX` — Paket direkt zurückschicken über dieselbe NIC
- (Bonus: `XDP_REDIRECT` — an anderes Interface weiterleiten)

**7. Was macht `SEC("xdp")` im C-Code?**

Ein Makro das dem Compiler sagt: "Leg diese Funktion in den ELF-Abschnitt namens `xdp`." Der Kernel liest diesen Abschnitt und weiß dadurch welcher Hook Point gemeint ist.

**8. Wie kommuniziert Cilium mit eBPF-Programmen im Kernel?**

Über eBPF Maps. Der Cilium Agent (Userspace) übersetzt Kubernetes NetworkPolicies in Security Identities (Zahlen) und schreibt sie in Maps. Das eBPF-Programm macht nur einen Hash-Lookup: `identity_src + identity_dst → erlaubt oder DROP`.

---

## Lab

### Vorbereitung

```bash
sudo apt install clang libbpf-dev linux-headers-$(uname -r)
```

### Aufgabe 1 — geladene eBPF-Programme beobachten

Zeige alle aktuell im Kernel geladenen eBPF-Programme. Welche Hook-Types siehst du?

### Aufgabe 2 — eBPF Maps inspizieren

Zeige alle Maps. Was ist der Unterschied zwischen `prog_array` und `hash`?

### Aufgabe 3 — Netzwerk-Hooks prüfen

Welcher Befehl zeigt dir ob eBPF-Programme an Netzwerk-Interfaces hängen?

### Aufgabe 4 — XDP Drop All

Schreibe ein XDP-Programm das alle Pakete verwirft. Kompiliere es und lade es auf `enp0s1`.
Was passiert mit deiner SSH-Verbindung?

### Aufgabe 5 — XDP selektives Drop

Schreibe ein XDP-Programm das nur ICMP-Pakete dropped, alles andere durchlässt.
Teste mit `ping` vom Mac — bleibt SSH erreichbar?

### Aufgabe 6 — Inspektion

Wie findest du heraus welches eBPF-Programm aktuell an `enp0s1` hängt und was seine ID ist?

### Aufgabe 7 — Aufräumen

Wie entfernst du ein XDP-Programm von einem Interface?
