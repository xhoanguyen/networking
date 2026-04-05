# Tag 7 — RFCs: Die Regeln des Internets

## Leseauftrag

- **Zisler** Kap. 1.5 (S. 29-31): Regel- und Nachschlagewerk für TCP/IP-Netze
- **Dordal** Kap. 1.15 (optional): IETF und das RFC-System

## Kernkonzepte

- [x] RFC = Request for Comments — die technischen Standards des Internets
- [x] IETF = Internet Engineering Task Force — verwaltet RFCs
- [x] Status-Stufen: Proposed Standard → Draft Standard → Standard
- [x] Verbindlichkeit: required, recommended, elective, not recommended
- [x] RFCs sind in englischer Sprache, frei zugänglich
- [x] Wichtige RFCs kennen: z.B. RFC 791 (IPv4), RFC 793 (TCP)

## Flashcards

**Q:** Was ist ein RFC?
**A:** Request for Comments — ein Dokument, das einen Internetstandard oder eine technische Spezifikation beschreibt. Verwaltet von der IETF, frei zugänglich.

**Q:** Wann ist ein RFC verbindlich anzuwenden?
**A:** Wenn er als "required" gekennzeichnet ist. "Recommended" = dringend empfohlen, "elective" = optional.

**Q:** Was ist die IETF?
**A:** Internet Engineering Task Force — die Organisation, die Internetstandards (RFCs) entwickelt und verwaltet. Arbeitet nach dem Prinzip "rough consensus and running code".

**Q:** Nenne 3 wichtige RFCs.
**A:** RFC 791 (IPv4), RFC 793 (TCP), RFC 2616 (HTTP/1.1) — alle frei lesbar unter tools.ietf.org.

## IETF und RFCs: Hintergrund

Die IETF (Internet Engineering Task Force) wurde 1986 gegründet. Sie hat keine formelle Mitgliedschaft — wer mitmachen will, macht einfach mit. Das Arbeitsprinzip lautet "rough consensus and running code": ein Standard wird nicht verabschiedet weil ein Komitee zustimmt, sondern weil er in der Praxis funktioniert und breite Unterstützung hat. RFCs sind nummeriert und unveränderlich — wird ein Standard überarbeitet, bekommt er eine neue Nummer. Nicht jeder RFC ist ein Standard: manche sind informational, experimental oder beschreiben "best current practice".

## Mini-Quiz

1. Was unterscheidet "required" von "recommended" bei einem RFC?
2. Wo findest du RFC-Dokumente online?
3. Warum sind offene Standards (RFCs) wichtig für die Interoperabilität im Internet?

### Antworten

**1.** "required" heißt: muss implementiert werden, keine Ausnahme. "recommended" heißt: sollte implementiert werden, aber es gibt Situationen wo man begründet abweichen kann. "elective" ist optional, je nach Bedarf.

**2.** Unter [datatracker.ietf.org](https://datatracker.ietf.org) oder [tools.ietf.org](https://tools.ietf.org).

**3.** Weil jeder die Spezifikation lesen und eine eigene Implementierung bauen kann — alle folgen denselben Regeln. Das ist der Grund warum ein macOS-Client mit einem Linux-Server kommunizieren kann, obwohl beide unabhängig voneinander entwickelt wurden.

## RZ-Relevanz

Im RZ arbeitet man täglich mit RFC-definierten Protokollen, oft ohne es bewusst zu merken. Wenn ein HTTP-Request mit Status 301 zurückkommt, ist das ein RFC-definierter Statuscode. Wenn TLS den Handshake aufbaut, folgt das RFC 8446. Wenn sich ein Protokoll unerwartet verhält, hilft ein Blick in den RFC um zu verstehen ob das erwartetes Verhalten ist oder ein Bug. Wer weiß dass RFC 793 beschreibt wie TCP Verbindungen aufbaut und abbaut, kann bei Verbindungsproblemen gezielter debuggen statt zu raten.
