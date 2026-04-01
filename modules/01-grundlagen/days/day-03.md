# Tag 3 — Das OSI-Schichtenmodell

## Leseauftrag

- **Zisler** Kap. 1.3 (S. 23-27): OSI-Schichtenmodell und TCP/IP-Referenzmodell
- **Dordal** Kap. 1.1, 1.15 (optional): Schichten als APIs, IETF vs. OSI

## Kernkonzepte

- [x] Warum Schichtenmodelle? Abstraktion der Kommunikation
- [x] OSI-Modell: 7 Schichten (Physical → Application)
- [x] Datenfluss: virtuell horizontal, real vertikal (runter → Medium → rauf)
- [x] Jede Schicht hat eine klar definierte Aufgabe
- [x] Dordal-Perspektive: Schichten als Programmierschnittstellen (APIs)

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
   > **Switch → Layer 2 (Data Link):** Arbeitet mit MAC-Adressen und leitet Frames im LAN weiter. **Router → Layer 3 (Network):** Arbeitet mit IP-Adressen und verbindet verschiedene Netzwerke miteinander (nicht nur Internet — auch Subnetze im RZ).
   > *Quelle: Zisler Kap. 1.3; allgemeines Netzwerkwissen*

2. Warum kritisiert Dordal das OSI-Modell als teilweise "undurchsichtig"?
   > Die Schichten 5 (Session) und 6 (Presentation) sind unklar definiert und in der Praxis kaum von der Anwendungsschicht trennbar. Das OSI-Modell ist ein theoretisches Komitee-Produkt (ISO), während TCP/IP aus praktischer Implementierung entstand und mit 4 Schichten auskommt. Zudem arbeiten reale Geräte oft über mehrere Schichten hinweg (z.B. Layer-3-Switch).
   > *Quelle: Dordal Kap. 1.1, 1.15*

3. Welche Schicht ist für MAC-Adressen zuständig?
   > **Layer 2 (Data Link)** — MAC-Adressen sind Hardware-Adressen der Netzwerkkarten. Der Switch nutzt sie, um Frames im LAN an das richtige Gerät weiterzuleiten.
   > *Quelle: Zisler Kap. 1.3*
