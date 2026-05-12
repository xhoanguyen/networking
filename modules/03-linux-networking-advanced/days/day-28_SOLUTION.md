# Tag 28 — eBPF Fundamentals: SOLUTION

## Konzepte

### Was ist eBPF?

Extended Berkeley Packet Filter. Erlaubt es, eigene Programme sicher im Linux-Kernel auszuführen — ohne den Kernel neu zu kompilieren. Wie JavaScript für den Kernel, aber mit Sicherheitsschleuse (Verifier).

### Der Weg eines eBPF-Programms

```
C-Code schreiben
      ↓
clang → eBPF Bytecode (.o Datei)
      ↓
Kernel lädt Bytecode
      ↓
Verifier prüft: sicher? terminiert? keine OOB-Zugriffe?
      ↓
JIT-Compiler → nativer Maschinencode (aarch64, x86_64...)
      ↓
Hook Point anhängen (XDP / TC / cgroup / kprobe...)
      ↓
Event → Programm wird ausgeführt
```

### XDP vs iptables

```
Normal (iptables):
Paket → sk_buff anlegen → Speicher allozieren → iptables-Regeln → DROP → sk_buff freigeben
                                                                          ↑ alles umsonst

XDP:
Paket → DROP
        ↑ fertig, kein Speicher, keine Regeln
```

### Wie Cilium eBPF Maps nutzt

```
Kubernetes API
      │  "NetworkPolicy: Pod A → Pod B erlaubt"
      ↓
Cilium Agent (Userspace)
      │  übersetzt → identity_src=42, identity_dst=7 → value=1
      │  schreibt in eBPF Map
      ↓
eBPF Programm (Kernel)
      │  lookup(42, 7) → 1 → XDP_PASS
      ↓
```

Der Cilium Agent ist das Bindeglied: er watchт den API-Server, übersetzt Policies in Zahlen, schreibt Maps, lädt eBPF-Programme.

---

## Lab Lösungen

### Aufgabe 1 — geladene eBPF-Programme

```bash
sudo bpftool prog list
```

Zeigt alle Programme mit: ID, Typ (xdp, cgroup_device, tracing...), Name, JIT-Größe, Load-Zeitpunkt.

```bash
sudo bpftool prog show id <ID>
```

### Aufgabe 2 — eBPF Maps

```bash
sudo bpftool map list
```

- `prog_array` — Sprungtabelle zu anderen eBPF-Programmen (Tail Calls)
- `hash` — Key-Value Store, O(1) Lookup (wie FDB bei Bridges)

### Aufgabe 3 — Netzwerk-Hooks

```bash
sudo bpftool net list
```

Zeigt XDP, TC, flow_dissector und netfilter Hooks pro Interface.

### Aufgabe 4 — XDP Drop All

```bash
cat > xdp_drop.c << 'EOF'
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

SEC("xdp")
int xdp_drop_all(struct xdp_md *ctx) {
    return XDP_DROP;
}

char _license[] SEC("license") = "GPL";
EOF

clang -O2 -target bpf -I/usr/include/aarch64-linux-gnu -c xdp_drop.c -o xdp_drop.o
sudo ip link set dev enp0s1 xdp obj xdp_drop.o sec xdp
```

SSH-Verbindung bricht sofort ab — alle Pakete werden gedroppt, TCP kommt nicht mehr durch.

Wiederherstellen:
```bash
multipass stop --force rz-node && multipass start rz-node
```

### Aufgabe 5 — XDP selektives ICMP Drop

```bash
cat > xdp_drop_icmp.c << 'EOF'
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <linux/ip.h>

SEC("xdp")
int xdp_drop_icmp(struct xdp_md *ctx) {
    void *data = (void *)(long)ctx->data;
    void *data_end = (void *)(long)ctx->data_end;

    struct ethhdr *eth = data;
    if ((void *)(eth + 1) > data_end)
        return XDP_PASS;

    if (eth->h_proto != __constant_htons(ETH_P_IP))
        return XDP_PASS;

    struct iphdr *ip = (void *)(eth + 1);
    if ((void *)(ip + 1) > data_end)
        return XDP_PASS;

    if (ip->protocol == 1)
        return XDP_DROP;

    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
EOF

clang -O2 -target bpf -I/usr/include/aarch64-linux-gnu -c xdp_drop_icmp.c -o xdp_drop_icmp.o
sudo ip link set dev enp0s1 xdp obj xdp_drop_icmp.o sec xdp
```

Test vom Mac:
```bash
ping 192.168.2.2   # → 100% packet loss
ssh ubuntu@192.168.2.2  # → funktioniert noch (SSH = TCP, Protokoll 6)
```

**Warum SSH noch funktioniert:** `ip->protocol == 1` ist ICMP. TCP hat Protokoll-Nummer 6 — wird durchgelassen.

**Code-Erklärung:**
- `ctx->data` / `ctx->data_end` — Anfang und Ende des Pakets im Speicher
- `struct ethhdr *eth = data` — Ethernet-Header über die Bytes legen
- `(void *)(eth + 1) > data_end` — Sicherheitsprüfung, vom Verifier erzwungen
- `eth->h_proto` — Protokoll-Feld im Ethernet-Header (`->` = Feld eines Struct-Pointers)
- `__constant_htons()` — Byte-Reihenfolge: Netzwerk = Big-Endian, CPU = Little-Endian
- `ip->protocol == 1` — 1 = ICMP im IP-Header

### Aufgabe 6 — Inspektion

```bash
sudo bpftool net list
# → zeigt enp0s1(2) driver id 24

sudo bpftool prog show id 24
# → name xdp_drop_icmp, jited 200B, loaded_at ...
```

### Aufgabe 7 — Aufräumen

```bash
sudo ip link set dev enp0s1 xdp off
sudo bpftool net list  # → wieder leer
```

---

## RZ Profi-Tipp

`bpftool prog list` ist der erste Check wenn Cilium auf einem Node Probleme macht. Cilium lädt bei Start ~20-30 eBPF-Programme. Fehlen Programme, weißt du sofort wo das Problem liegt — lange bevor `cilium status` einen Hinweis gibt. In der Praxis: `sudo bpftool prog list | grep cilium` auf dem betroffenen Node.
