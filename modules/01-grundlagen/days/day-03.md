# Tag 3 — Das OSI-Schichtenmodell

## Leseauftrag

- **Zisler** Kap. 1.3 (S. 23-27): OSI-Schichtenmodell und TCP/IP-Referenzmodell
- **Dordal** Kap. 1.1, 1.15 (optional): Schichten als APIs, IETF vs. OSI

## Kernkonzepte

- [ ] Warum Schichtenmodelle? Abstraktion der Kommunikation
- [ ] OSI-Modell: 7 Schichten (Physical → Application)
- [ ] Datenfluss: virtuell horizontal, real vertikal (runter → Medium → rauf)
- [ ] Jede Schicht hat eine klar definierte Aufgabe
- [ ] Dordal-Perspektive: Schichten als Programmierschnittstellen (APIs)

## Flashcards

**Q:** Nenne die 7 Schichten des OSI-Modells (von unten nach oben).
**A:** 1) Physical, 2) Data Link, 3) Network, 4) Transport, 5) Session, 6) Presentation, 7) Application

**Q:** Wie merkt man sich die 7 OSI-Schichten?
**A:** Eselsbrücke: **P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way

**Q:** Was bedeutet "virtuell horizontal, real vertikal"?
**A:** Zwei Rechner kommunizieren logisch auf der gleichen Schicht (z.B. Transport↔Transport), aber physisch fließen die Daten von der Anwendungsschicht nach unten durchs Kabel und beim Empfänger wieder nach oben.

**Q:** Was macht die Vermittlungsschicht (Layer 3)?
**A:** Routing und logische Adressierung (IP-Protokoll). Bestimmt den Weg eines Pakets durch das Netzwerk.

**Q:** Was macht die Transportschicht (Layer 4)?
**A:** Regelt die Kommunikation zwischen Anwendungen (TCP für zuverlässig, UDP für schnell). Zuständig für Segmentierung und Flusskontrolle.

## Mini-Quiz

1. Auf welcher OSI-Schicht arbeitet ein Switch? Und ein Router?
2. Warum kritisiert Dordal das OSI-Modell als teilweise "undurchsichtig"?
3. Welche Schicht ist für MAC-Adressen zuständig?
