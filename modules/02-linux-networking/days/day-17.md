# Tag 17 — iptables: Wie der Kernel über Pakete entscheidet

## What are we doing today and why?

Deine Namespaces können sich gegenseitig pingen — aber sie kommen nicht ins Internet. Warum? Weil der Linux-Kernel Pakete nicht einfach blind weiterleitet. Er hat ein eingebautes Firewall-System das entscheidet: annehmen, weiterleiten, verwerfen. Dieses System heißt **Netfilter** — und `iptables` ist das Werkzeug um es zu konfigurieren.

**Warum:** Jeder Container, jede VM, jeder Kubernetes-Pod läuft hinter iptables-Regeln. Wer iptables nicht versteht, kann keine Container-Netzwerke debuggen, keine Firewall-Probleme lösen, und kein NAT konfigurieren. Das ist Grundwissen für jeden der im RZ arbeitet.

## Lesen (20 Min)

**Pflicht:**
- `man iptables` (auf der VM) — Überblick über Syntax und Optionen
- `man iptables-extensions` — Match-Module und Targets
- **LARTC Kapitel 9** — Paketfilterung mit Netfilter

**Optional:**
- **"Linux Firewalls"** — Michael Rash (No Starch Press) — iptables in der Tiefe
- **"Linux Network Administrator's Guide"** — Kapitel über Paketfilterung

## Kernkonzepte

- [ ] iptables hat **Tabellen** — `filter`, `nat`, `mangle`, `raw` — jede mit eigenem Zweck
- [ ] Jede Tabelle hat **Chains** — `INPUT`, `OUTPUT`, `FORWARD`, `PREROUTING`, `POSTROUTING`
- [ ] Ein Paket durchläuft Chains in einer festen Reihenfolge — das nennt sich **Netfilter-Hook**
- [ ] Jede Chain hat Regeln — das Paket wird gegen jede Regel geprüft, erste Übereinstimmung gewinnt
- [ ] Am Ende einer Chain entscheidet die **Policy**: `ACCEPT` oder `DROP`
- [ ] `filter` ist die Standard-Tabelle — hier lebt die Firewall
- [ ] `nat` ist die Tabelle für Adressübersetzung — hier lebt NAT (Tag 18)

## Flashcards

**Q:** Was ist der Unterschied zwischen `INPUT`, `OUTPUT` und `FORWARD`?
**A:** `INPUT` — Pakete die für den Host selbst bestimmt sind. `OUTPUT` — Pakete die der Host selbst sendet. `FORWARD` — Pakete die durch den Host durchgeleitet werden (z.B. von einem Namespace ins Internet).

**Q:** Warum gibt es mehrere Tabellen in iptables?
**A:** Trennung der Zuständigkeiten. `filter` entscheidet ob ein Paket durchkommt. `nat` übersetzt Adressen. `mangle` verändert Paket-Header. Jede Tabelle greift an anderen Netfilter-Hooks in den Kernel ein.

**Q:** Was passiert wenn kein Rule in einer Chain matched?
**A:** Die **Policy** der Chain greift — standardmäßig `ACCEPT`. In produktiven Firewalls setzt man die Policy auf `DROP` und erlaubt nur explizit.

**Q:** Was bedeutet Stateful Firewall bei iptables?
**A:** Das `conntrack`-Modul verfolgt Verbindungszustände: `NEW`, `ESTABLISHED`, `RELATED`, `INVALID`. Damit reicht eine Regel für ausgehende Verbindungen — die Antwort kommt automatisch durch.

## Lab: iptables kennenlernen

Alle Commands in der Multipass-VM (`multipass shell rz-node`).

**Ziel heute:** Verstehen wie iptables aufgebaut ist, Rules lesen und schreiben, den Paketfluss nachvollziehen.

```
Paket kommt an
      │
  PREROUTING (nat, mangle, raw)
      │
      ├── für diesen Host? → INPUT (filter) → Prozess
      │
      └── weitergeleitet? → FORWARD (filter) → POSTROUTING (nat, mangle)
                                                      │
                                                   raus
```

---

### Aufgabe 1 — Aktuelle Regeln anzeigen

Bevor du etwas änderst: Wie zeigst du alle aktuellen iptables-Regeln an — mit Zeilennummern und Packet-Countern?

---

### Aufgabe 2 — Eine einfache Regel schreiben

Du willst alle eingehenden ICMP-Pakete (Ping) auf dem Host blockieren.

Denk nach:
- Welche Chain betrifft eingehenden Traffic zum Host?
- Welches Protokoll ist ICMP?
- Was soll mit dem Paket passieren — `DROP` oder `REJECT`? Was ist der Unterschied?

---

### Aufgabe 3 — Regel testen und wieder entfernen

Teste deine Regel (ping von außen oder von einem Namespace). Danach: Wie entfernst du eine einzelne Regel wieder ohne alle Regeln zu löschen?

---

### Aufgabe 4 — FORWARD Chain verstehen

Schau dir die FORWARD Chain an:

```bash
sudo iptables -L FORWARD -v -n
```

Was siehst du? Was bedeutet das für Traffic der von einem Namespace ins Internet will?

---

### Aufgabe 5 — Conntrack: Verbindungszustände

```bash
sudo conntrack -L
```

Was zeigt conntrack? Ping von einem Namespace zur Bridge (`10.0.0.1`) und schau was sich ändert.

---

### Aufräumen

Setze alle Regeln zurück auf den Ausgangszustand.

## Mini-Quiz (Theorie)

1. **Ein Paket kommt von ns1 (10.0.0.2) und soll ins Internet.** Welche Chains durchläuft es auf dem Host — in welcher Reihenfolge?

2. **Du hast `iptables -A INPUT -j DROP` ausgeführt.** Was passiert jetzt mit SSH-Verbindungen zum Host?

3. **Was ist der Unterschied zwischen `DROP` und `REJECT`?** Wann nimmst du was im RZ?

## Reflexion

- [ ] Ich kann alle aktuellen iptables-Regeln anzeigen und lesen
- [ ] Ich verstehe den Unterschied zwischen Tabellen und Chains
- [ ] Ich kann eine einfache Regel hinzufügen und wieder entfernen
- [ ] Ich verstehe warum die FORWARD Chain für Namespaces relevant ist
- [ ] Ich kenne den Unterschied zwischen DROP und REJECT

## Faustregeln

**iptables:**
- `-L` → Rules anzeigen, `-A` → anhängen, `-I` → einfügen, `-D` → löschen, `-F` → alle löschen
- Immer `-v -n` bei `-L` — verbose und ohne DNS-Auflösung (schneller, klarer)
- Reihenfolge der Regeln matters — erste Übereinstimmung gewinnt

**Debugging:**
- `iptables -L -v -n --line-numbers` → Rules mit Nummern und Countern
- `conntrack -L` → aktive Verbindungen
- `iptables -t nat -L -v -n` → NAT-Tabelle anzeigen

**Merksatz:** *iptables ist der Türsteher des Kernels — er entscheidet für jedes Paket: rein, raus oder weiterschicken.*
