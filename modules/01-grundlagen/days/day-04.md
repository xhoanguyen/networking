# Tag 4 — TCP/IP-Referenzmodell vs. OSI

## Leseauftrag

- **Zisler** Kap. 1.3 nochmal (S. 25-27): Vergleich TCP/IP vs. OSI
- **Dordal** Kap. 1.15 (optional): IETF-Modell im Detail

## Kernkonzepte

- [x] TCP/IP-Modell: 4 Schichten (Netzzugang, Internet, Transport, Anwendung)
- [x] Alternativ 5 Schichten: Physical + Data Link getrennt
- [x] Zusammenfassung: OSI Session+Presentation+Application = TCP/IP Application
- [x] OSI = theoretischer Standard, TCP/IP = praxisorientiert
- [x] IETF vs. ISO: "running code" vs. Komitee-Arbeit

## Flashcards

**Q:** Nenne die 4 Schichten des TCP/IP-Modells.
**A:** 1) Netzzugang (Network Access), 2) Internet (IP), 3) Transport (TCP/UDP), 4) Anwendung (Application)

**Q:** Was ist der Hauptunterschied zwischen OSI und TCP/IP-Modell?
**A:** OSI hat 7 Schichten (theoretisch, von ISO), TCP/IP hat 4-5 Schichten (praxisorientiert, von IETF). TCP/IP fasst die oberen 3 OSI-Schichten (Session, Presentation, Application) zu einer zusammen.

**Q:** Was bedeutet das IETF-Prinzip "rough consensus and running code"?
**A:** Standards werden nicht theoretisch designed, sondern basierend auf funktionierenden Implementierungen und breiter Übereinstimmung verabschiedet — Praxis vor Theorie.

## Mini-Quiz

1. Welche OSI-Schichten fasst das TCP/IP-Modell zur Anwendungsschicht zusammen?

   **Schichten 5 (Session), 6 (Presentation) und 7 (Application)** werden zur TCP/IP-Anwendungsschicht zusammengefasst. Die Aufgaben von Session-Management und Datenformatierung werden in der Praxis direkt von der Anwendung selbst oder von Bibliotheken übernommen — eine separate Schicht dafür hat sich als unnötig erwiesen. Ebenso werden Schicht 1 (Physical) und 2 (Data Link) zum Netzzugang zusammengefasst, da TCP/IP sich bewusst nicht um die Details der physischen Übertragung kümmert. Das ergibt 4 Schichten insgesamt.

   > **Quellen:** Zisler Kap. 1.3

   > **RZ-Relevanz:** Das TCP/IP-Modell ist das Modell, mit dem im RZ tatsächlich gearbeitet wird. Jede Schicht hat konkrete Werkzeuge: Netzzugang → `ethtool`, `ip link`; Internet → `ip addr`, `ip route`; Transport → `ss`, `netstat`; Anwendung → `curl`, `dig`. Wenn ein Dienst im RZ nicht erreichbar ist, arbeitet man sich systematisch von unten nach oben durch diese 4 Schichten: Kabel/Link OK? → IP-Konnektivität? → Port offen? → Anwendung antwortet? Dieses Layer-by-Layer-Debugging ist der praktische Grund, warum das Schichtenmodell so wichtig ist.

---

2. Warum hat sich TCP/IP gegenüber dem OSI-Modell in der Praxis durchgesetzt?

   Drei entscheidende Faktoren: **Praxisnah** — die IETF arbeitet nach dem Prinzip "rough consensus and running code", d.h. Standards basieren auf funktionierenden Implementierungen statt auf Theorie. **Früh verbreitet** — durch 4.2BSD (Unix) kam TCP/IP kostenlos an jede Universität, Studierende trugen das Wissen in die Industrie. **Iterativ verbessert** — offene RFCs ermöglichten schnelle Weiterentwicklung durch die Community. Während die ISO noch am OSI-Protokollstack schrieb, lief TCP/IP bereits produktiv im ARPANET.

   > **Quellen:** Dordal Kap. 1.15; Zisler Kap. 1.3

   > **RZ-Relevanz:** Dasselbe Muster — offener Standard + freie Implementierung + Community-Weiterentwicklung — bestimmt heute die RZ-Landschaft. Linux hat sich gegen proprietäre Unix-Varianten durchgesetzt, Kubernetes gegen proprietäre Orchestrierungsplattformen, und Prometheus gegen kommerzielle Monitoring-Lösungen. Im Netzwerkbereich sieht man es bei eBPF/Cilium: eine offene Technologie, die klassische proprietäre Netzwerk-Appliances (Hardware-Firewalls, Load Balancer) zunehmend durch Software ersetzt. Die Lektion: Im RZ gewinnt langfristig fast immer die offene, community-getriebene Lösung.
