# Tag 28 — eBPF Grundlagen: Architektur, Maps, Programme

## Lernziel

eBPF ist die Technologie hinter Cilium, modernen Firewalls und Observability-Tools.
Du verstehst heute wie eBPF im Kernel funktioniert — bevor wir in Tag 29 in die Praxis gehen.

---

## Flashcards — erst durchgehen, dann Lab

**1. Was ist eBPF in einem Satz?**

eBPF erlaubt es, eigene Programme sicher im Linux-Kernel auszuführen — ohne den Kernel neu zu kompilieren oder das System neu zu starten.

**2. Wie läuft ein eBPF-Programm ab?**

1. Code in C/Rust schreiben
2. Mit LLVM/Clang zu eBPF-Bytecode kompilieren
3. Via `bpf()` Syscall in den Kernel laden
4. An einen Hook anhängen (z.B. eingehendes Paket)
5. Kernel führt das Programm bei jedem Event aus — in einer isolierten VM

**3. Was ist der Verifier?**

Die Sicherheitsschleuse des Kernels. Prüft jeden Bytecode bevor er ausgeführt wird:
- Keine ungültigen Speicherzugriffe
- Kein Endlosloop (Programm muss immer terminieren)
- Ausreichende Rechte (`CAP_NET_ADMIN`)

**4. Was macht der JIT-Compiler?**

Übersetzt den plattformunabhängigen eBPF-Bytecode in nativen CPU-Maschinencode (x86_64, ARM64).
Ergebnis: Performance fast identisch mit fest im Kernel kompiliertem Code.

**5. Was sind eBPF Maps?**

Key-Value-Speicher im Kernel — das Gedächtnis von eBPF-Programmen.
Nutzung: Paketzähler, IP-Whitelists, Routing-Tabellen, Verbindungsstatus.

**6. Welche Map-Typen sind für Networking relevant?**

| Typ | Nutzung |
|-----|---------|
| `BPF_MAP_TYPE_HASH` | IP-Adressen nachschlagen |
| `BPF_MAP_TYPE_LPM_TRIE` | Longest Prefix Match — IP-Routing |
| `BPF_MAP_TYPE_SOCKMAP` | Traffic zwischen Sockets umleiten |

**7. Was sind Helper Functions?**

Kontrollierte Kernel-API für eBPF-Programme — da Programme nicht direkt Kernel-Funktionen aufrufen dürfen.
Wichtige Beispiele: `bpf_redirect()`, `bpf_skb_load_bytes()`, `bpf_map_lookup_elem()`

**8. Was sind die wichtigsten eBPF Programm-Typen für Networking?**

| Typ | Hook | Nutzung |
|-----|------|---------|
| XDP | Netzwerkkartentreiber (vor dem Kernel-Stack) | DDoS-Abwehr, Load Balancer |
| tc | Traffic Control (Ingress + Egress) | Paketmanipulation, Filtering |
| Socket Filter | Socket | Monitoring (wie tcpdump) |
| kprobe | Kernel-Funktion | Debugging, Observability |

---

## Theorie

### Der Weg eines eBPF-Programms

```
Developer schreibt C-Code
        ↓
LLVM/Clang → eBPF Bytecode
        ↓
bpf() Syscall → Kernel
        ↓
Verifier prüft: sicher? terminiert? Rechte ok?
        ↓
JIT-Compiler → nativer Maschinencode
        ↓
Hook anhängen (XDP / tc / kprobe / ...)
        ↓
Event tritt auf → Programm wird ausgeführt
```

### XDP — der schnellste Hook

XDP läuft direkt im Netzwerkkartentreiber — bevor der Kernel-Stack das Paket sieht:

```
NIC empfängt Paket
    ↓
XDP-Programm (noch im Treiber)
    ↓ Return-Code entscheidet:
    XDP_DROP    → Paket verwerfen (DDoS-Abwehr)
    XDP_PASS    → Normal weiterleiten an Kernel-Stack
    XDP_TX      → Zurück zur NIC senden
    XDP_REDIRECT → An anderes Interface weiterleiten
```

Das macht XDP extrem schnell — kein sk_buff allokiert, kein Kernel-Stack durchlaufen.

### tc — flexibler als XDP

tc-Programme hängen am Traffic Control Subsystem und sehen den vollen `sk_buff`:

```
Ingress: Pakete eingehend prüfen/manipulieren
Egress:  Pakete ausgehend prüfen/manipulieren
```

Cilium nutzt tc-Programme für Network Policies und Service Load Balancing.

### Maps — Kommunikation zwischen Kernel und User-Space

```
Kernel (eBPF-Programm)          User-Space (bpftool / Python)
        ↓                               ↑
    map_update_elem()          bpftool map dump
    map_lookup_elem()          bpftool map update
        ↓                               ↑
        └──────── eBPF Map ─────────────┘
```

So funktioniert z.B. eine dynamische Firewall: User-Space schreibt IPs in die Map, eBPF-Programm liest und dropped.

### Warum ist das für das RZ relevant?

- **Cilium** nutzt eBPF für alle Network Policies, Service Load Balancing und Observability
- **Ohne eBPF-Verständnis** ist Cilium-Debugging eine Blackbox
- **bpftool** ist das erste Werkzeug bei Cilium-Incidents auf Node-Ebene

---

## Lab

### Vorbereitung

```bash
# eBPF-Tools installieren
sudo apt-get update
sudo apt-get install -y bpftool bpftrace linux-tools-common linux-tools-$(uname -r)

# Kernel-Features prüfen
bpftool feature
```

### Aufgabe 1 — geladene eBPF-Programme beobachten

Zeige alle aktuell im Kernel geladenen eBPF-Programme:

```bash
sudo bpftool prog list
```

Was siehst du? Gibt es bereits Programme? (Multipass/Ubuntu lädt oft eigene.)

### Aufgabe 2 — eBPF Maps inspizieren

```bash
sudo bpftool map list
```

Wähle eine Map aus und zeige ihren Inhalt:

```bash
sudo bpftool map dump id <ID>
```

### Aufgabe 3 — bpftrace Einzeiler

bpftrace ist wie awk für den Kernel. Zähle alle TCP-Verbindungen live:

```bash
sudo bpftrace -e 'kprobe:tcp_connect { @connections[comm] = count(); }'
```

Öffne in einem zweiten Terminal `curl https://example.com` — was siehst du?

Beende mit Ctrl+C. bpftrace gibt die Zusammenfassung aus.

### Aufgabe 4 — Kernel-Features prüfen

```bash
sudo bpftool feature | grep -E "xdp|tc|map"
```

Welche XDP-Modi unterstützt dein System? Was bedeutet `native` vs `generic`?

### Aufgabe 5 — Verifier-Fehler verstehen (Theorie)

Folgende eBPF-Programme würde der Verifier ablehnen — erkläre warum:

```c
// Beispiel A
int *val = bpf_map_lookup_elem(&my_map, &key);
return *val;  // Was fehlt hier?

// Beispiel B
for (int i = 0; i < 1000000; i++) {
    // Endlosschleife
}
```

---

## RZ Profi-Tipp

Wenn Cilium auf einem Node Probleme macht, ist `bpftool prog list` der erste Check. Cilium lädt bei Start ~20-30 eBPF-Programme. Fehlen Programme oder zeigen sie `err` im Status, weißt du sofort wo das Problem liegt — lange bevor `cilium status` einen Hinweis gibt.
