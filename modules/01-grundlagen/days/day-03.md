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

   **Switch → Layer 2 (Data Link):** Ein Switch arbeitet mit MAC-Adressen und leitet Frames innerhalb eines lokalen Netzwerks (LAN) weiter. Er lernt, welche MAC-Adresse an welchem Port hängt, und leitet Frames gezielt nur an den richtigen Port weiter — statt wie ein Hub alles an alle zu senden.

   **Router → Layer 3 (Network):** Ein Router arbeitet mit IP-Adressen und verbindet verschiedene Netzwerke miteinander. Das kann die Verbindung zum Internet sein, aber im Rechenzentrum verbindet er typischerweise verschiedene Subnetze untereinander (z.B. Management-Netz, Storage-Netz, Produktions-Netz).

   > **Quellen:** Zisler Kap. 1.3; allgemeines Netzwerkwissen

   > **RZ-Relevanz:** Im Rechenzentrum begegnet man beiden Geräten ständig — oft sogar kombiniert als Layer-3-Switch, der sowohl Switching (L2) als auch Routing (L3) beherrscht. Die Trennung in verschiedene Subnetze (z.B. über VLANs auf L2 und Routing auf L3) ist ein Grundprinzip der RZ-Netzwerkarchitektur: Management-Traffic, Storage-Traffic und Applikations-Traffic werden getrennt, um Sicherheit und Performance zu gewährleisten. In Kubernetes-Umgebungen übernehmen CNI-Plugins wie Cilium oder Calico ähnliche Routing-Aufgaben auf Software-Ebene.

---

2. Warum kritisiert Dordal das OSI-Modell als teilweise "undurchsichtig"?

   Die Schichten 5 (Session) und 6 (Presentation) sind unklar definiert und lassen sich in der Praxis kaum von der Anwendungsschicht trennen. Das OSI-Modell wurde als theoretisches Komitee-Produkt (ISO) entworfen, während TCP/IP aus der praktischen Implementierung gewachsen ist und deshalb mit 4 Schichten auskommt. Zudem arbeiten reale Geräte häufig über mehrere Schichten hinweg — ein moderner Layer-3-Switch vereint z.B. Switching (L2) und Routing (L3) in einem Gerät.

   > **Quellen:** Dordal Kap. 1.1, 1.15

   > **RZ-Relevanz:** Auch im RZ-Alltag verschwimmen die Schichten: Ein Load Balancer kann auf Layer 4 (TCP-Port) oder Layer 7 (HTTP-Header, URL-Pfad) arbeiten. Firewalls inspizieren oft bis Layer 7 (Deep Packet Inspection). Diese Realität zeigt, warum das starre 7-Schichten-Modell eher als Denkmodell taugt als als exakte Abbildung der Praxis. Trotzdem ist die OSI-Terminologie im RZ-Umfeld allgegenwärtig — wenn jemand von einem "L4-Service" oder "L7-Ingress" spricht, bezieht sich das auf die OSI-Schichten.

---

3. Welche Schicht ist für MAC-Adressen zuständig?

   **Layer 2 (Data Link)** — MAC-Adressen sind die Hardware-Adressen der Netzwerkkarten (NICs). Sie sind 48 Bit lang und weltweit eindeutig (z.B. `aa:bb:cc:dd:ee:ff`). Der Switch nutzt seine MAC-Adresstabelle, um eingehende Frames anhand der Ziel-MAC-Adresse an den richtigen Port weiterzuleiten.

   > **Quellen:** Zisler Kap. 1.3

   > **RZ-Relevanz:** MAC-Adressen spielen im RZ eine wichtige Rolle bei der Fehlersuche und Sicherheit. Mit ARP-Tabellen lässt sich nachvollziehen, welches Gerät welche IP hat. MAC-basierte Zugriffskontrolle (Port Security) kann verhindern, dass unautorisierte Geräte ans Netz angeschlossen werden. In virtualisierten Umgebungen bekommen VMs und Container eigene virtuelle MAC-Adressen — bei Kubernetes z.B. generiert das CNI-Plugin für jeden Pod eine MAC-Adresse auf dem virtuellen Netzwerk-Interface (veth-Pair).
