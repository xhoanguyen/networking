# Flashcards — Modul 01: Grundlagen

## Netzwerk-Basics

**Q:** Was bedeutet "paketorientiert"?
**A:** Daten werden in kleine Einheiten (Pakete) aufgeteilt, die eigenständig ihren Weg zum Ziel finden — im Gegensatz zur leitungsvermittelten Kommunikation.

**Q:** Was ist ein heterogenes Netz?
**A:** Ein Netzwerk mit verschiedenen Hardware-Architekturen und Betriebssystemen, die gleichberechtigt kommunizieren.

**Q:** Was sind die drei Hauptaufgaben eines Netzwerkprotokolls?
**A:** 1) Adressierung, 2) Verbindungs-/Flusssteuerung, 3) Fehlererkennung.

**Q:** Was ist der Unterschied zwischen Datenrate, Durchsatz und Goodput?
**A:** Datenrate = reine Bitrate. Durchsatz = effektive Rate inkl. Overhead. Goodput = nutzbare Daten auf Anwendungsebene.

## TCP/IP

**Q:** Wann und wo entstand TCP/IP?
**A:** 1970er-Jahre, ARPA-Projekt. Durchbruch durch 4.2BSD (Berkeley Unix).

**Q:** Warum setzte sich TCP/IP durch?
**A:** Architekturunabhängig, offene Standards, praktische Referenzimplementierung in BSD Unix.

**Q:** Nenne die 4 TCP/IP-Schichten.
**A:** 1) Netzzugang, 2) Internet (IP), 3) Transport (TCP/UDP), 4) Anwendung

## OSI-Modell

**Q:** Nenne die 7 OSI-Schichten (unten → oben).
**A:** Physical, Data Link, Network, Transport, Session, Presentation, Application. Merke: **P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way

**Q:** Was bedeutet "virtuell horizontal, real vertikal"?
**A:** Logisch kommunizieren gleiche Schichten (z.B. Transport↔Transport), physisch fließen Daten vertikal durch alle Schichten.

**Q:** Hauptunterschied OSI vs. TCP/IP?
**A:** OSI = 7 Schichten (theoretisch). TCP/IP = 4 Schichten (praxisorientiert). TCP/IP fasst Session+Presentation+Application zusammen.

**Q:** Was macht Layer 2 (Data Link)?
**A:** MAC-Adressen und Zugriffssteuerung.

**Q:** Was macht Layer 3 (Network)?
**A:** Routing und logische Adressierung (IP).

**Q:** Was macht Layer 4 (Transport)?
**A:** Kommunikation zwischen Anwendungen (TCP/UDP), Segmentierung, Flusskontrolle.

## Netzwerktypen

**Q:** PAN, LAN, MAN, WAN — was ist was?
**A:** PAN = ein Raum (Bluetooth). LAN = Gebäude. MAN = Campus/Stadt. WAN = überregional/weltweit.

**Q:** Was ist ein Intranet?
**A:** Privates Netzwerk mit TCP/IP, nicht aus dem Internet erreichbar.

**Q:** Was ist Mesh-Topologie?
**A:** Jeder Knoten mit mehreren verbunden. Hohe Redundanz, aber komplex.

## RFCs & Standards

**Q:** Was ist ein RFC?
**A:** Request for Comments — Internetstandard-Dokument, verwaltet von der IETF.

**Q:** Wann ist ein RFC verbindlich?
**A:** Wenn als "required" gekennzeichnet.

**Q:** Was ist die IETF?
**A:** Internet Engineering Task Force — entwickelt Internetstandards nach "rough consensus and running code".

## Pakete & Routing

**Q:** Unterschied Weiterleitung vs. Routing?
**A:** Weiterleitung = Paket zum nächsten Hop schicken. Routing = Tabellen aufbauen/aktualisieren.

**Q:** Was steht in einer Weiterleitungstabelle?
**A:** <Ziel, Next_Hop>-Paare — pro Zielnetz der nächste Router.

**Q:** Was ist TTL?
**A:** Time to Live — wird pro Hop um 1 reduziert, bei 0 wird Paket verworfen. Verhindert Routing-Schleifen.

**Q:** Was ist Congestion?
**A:** Überlast — mehr Daten als das Netz verarbeiten kann → Paketverlust, erhöhte Latenz.

## IP, DNS, Transport

**Q:** Warum Netzwerkpräfixe statt Hostadressen?
**A:** Skalierbarkeit — Milliarden Hosts, aber nur ~800k Routing-Einträge durch Zusammenfassung.

**Q:** Was macht DNS?
**A:** Übersetzt Hostnamen → IP-Adressen.

**Q:** TCP vs. UDP?
**A:** TCP = zuverlässig, verbindungsorientiert (Web, Mail). UDP = schnell, verbindungslos (DNS, Streaming).

**Q:** Was ist ein CDN?
**A:** Content Distribution Network — Inhalte auf Edge-Servern nahe am Nutzer repliziert.
