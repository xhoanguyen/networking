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
   > **Schichten 5 (Session), 6 (Presentation) und 7 (Application)** werden zur TCP/IP-Anwendungsschicht zusammengefasst. Ebenso werden Schicht 1 (Physical) und 2 (Data Link) zum Netzzugang zusammengefasst — ergibt 4 Schichten insgesamt.
   > *Quelle: Zisler Kap. 1.3*

2. Warum hat sich TCP/IP gegenüber dem OSI-Modell in der Praxis durchgesetzt?
   > **Praxisnah** (IETF: "rough consensus and running code"), **früh verbreitet** (4.2BSD/Unix brachte TCP/IP kostenlos an Unis) und **iterativ verbessert** (offene RFCs). Während ISO noch am Standard schrieb, lief TCP/IP bereits im ARPANET.
   > *Quelle: Dordal Kap. 1.15; Zisler Kap. 1.3*
