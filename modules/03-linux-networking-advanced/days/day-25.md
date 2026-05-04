# Tag 25 — STP: Spanning Tree Protocol

> **Notiz:** Aufgehängt aus dem Tag-20 Final Exam — STP als Ursache für `state disabled` auf Bridge-Ports war unbekannt.
>
> Themen:
> - Was ist STP und warum existiert es? (Loop-Prevention auf L2)
> - Bridge States: `disabled`, `blocking`, `listening`, `learning`, `forwarding`
> - Root Bridge Election
> - RSTP (Rapid STP) — moderner Standard
> - Wie prüft man STP-Status auf Linux? (`bridge link show`, `bridge stp`)
> - Wann aktiviert/deaktiviert man STP im RZ?

**Block B — Subnetz-Masken und Connected Routes**
- Was macht der Kernel wenn eine IP mit /32 konfiguriert ist?
- Warum legt /24 automatisch eine Connected Route an, /32 nicht?
- Konkret: `10.0.0.2/32` will `10.0.0.3` pingen → kein ARP, warum?
- Routing-Tabelle lesen und verstehen: `ip route show` Schritt für Schritt

Inhalt wird on-demand erstellt wenn Tag 24 abgeschlossen ist.
