# Flashcards — Modul 01: Grundlagen

## Netzwerk-Basics

**Q:** Was bedeutet "paketorientiert"?
**A:** Daten werden in kleine Einheiten (Pakete) aufgeteilt, die eigenständig ihren Weg zum Ziel finden — im Gegensatz zur leitungsvermittelten Kommunikation.
**Warum wichtig:** Pakete können unterschiedliche Routen nehmen und finden eigenständig ihr Ziel — das ist der Grundmechanismus hinter der Robustheit des Internets.

**Q:** Was ist ein heterogenes Netz?
**A:** Ein Netzwerk mit verschiedenen Hardware-Architekturen und Betriebssystemen, die gleichberechtigt kommunizieren.
**Warum wichtig:** In der Praxis siehst du nie ein reines One-Vendor-Netz — du musst verstehen, warum Protokolle wie TCP/IP überhaupt existieren.

**Q:** Was sind die drei Hauptaufgaben eines Netzwerkprotokolls?
**A:** 1) Adressierung, 2) Verbindungs-/Flusssteuerung, 3) Fehlererkennung.
**Warum wichtig:** Wenn du weißt, was ein Protokoll leisten muss, kannst du jedes neue Protokoll sofort einordnen — z.B. "macht TCP Fehlererkennung? Ja. Macht UDP das? Nein — warum nicht?"

**Q:** Was ist der Unterschied zwischen Datenrate, Durchsatz und Goodput?
**A:** Datenrate = reine Bitrate. Durchsatz = effektive Rate inkl. Overhead. Goodput = nutzbare Daten auf Anwendungsebene.
**Warum wichtig:** In der Praxis verkauft dir jeder ISP die "Datenrate" — aber was du wirklich kriegst ist Goodput. Der Unterschied kann erheblich sein.

## TCP/IP

**Q:** Wann und wo entstand TCP/IP?
**A:** 1970er-Jahre, ARPA-Projekt. Durchbruch durch 4.2BSD (Berkeley Unix).
**Warum wichtig:** Du verstehst dann, warum das Internet so dezentral und robust designed wurde — es war militärisch motiviert, sollte auch bei Teilausfällen funktionieren.

**Q:** Warum setzte sich TCP/IP durch?
**A:** Architekturunabhängig, offene Standards, praktische Referenzimplementierung in BSD Unix.
**Warum wichtig:** Technisch überlegene Protokolle scheitern oft — TCP/IP gewann nicht weil es perfekt war, sondern weil es offen und pragmatisch war. Das Muster wiederholt sich in der Tech-Geschichte ständig.

**Q:** Nenne die 4 TCP/IP-Schichten.
**A:** 1) Netzzugang, 2) Internet (IP), 3) Transport (TCP/UDP), 4) Anwendung
**Warum wichtig:** Das ist dein mentales Grundgerüst — jedes Protokoll das du je lernst, ordnest du hier ein. Ohne das hängt alles in der Luft.

## OSI-Modell

**Q:** Nenne die 7 OSI-Schichten (unten → oben).
**A:** Physical, Data Link, Network, Transport, Session, Presentation, Application. Merke: **P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way
**Warum wichtig:** Jeder in Networking spricht in OSI-Schichten. "L3-Problem", "L7-Firewall", "L2-Loop" — ohne das bist du in keinem Tech-Gespräch dabei.

**Q:** Was bedeutet "virtuell horizontal, real vertikal"?
**A:** Logisch kommunizieren gleiche Schichten (z.B. Transport↔Transport), physisch fließen Daten vertikal durch alle Schichten — beim Sender von oben nach unten (Encapsulation), beim Empfänger von unten nach oben (Decapsulation).
**Warum wichtig:** Das erklärt warum Protokolldesign funktioniert — jede Schicht "denkt" sie spricht direkt mit der Gegenseite, dabei läuft alles physisch durch den Stack. Das ist die Magie der Abstraktion.

**Q:** Hauptunterschied OSI vs. TCP/IP?
**A:** OSI = 7 Schichten, theoretisches Referenzmodell, nie vollständig implementiert. TCP/IP = 4 Schichten, praxisorientiert, fasst Session+Presentation+Application zusammen. OSI wird heute als gemeinsame Sprache genutzt — TCP/IP läuft tatsächlich im Internet.
**Warum wichtig:** In Interviews und Dokumentationen wirst du beiden Modellen begegnen. Du musst wissen warum TCP/IP gewann und wo OSI noch relevant ist.

**Q:** Was macht Layer 2 (Data Link)?
**A:** MAC-Adressen und Zugriffssteuerung — regelt wie ein Frame vom Gerät zum nächsten Gerät im selben Netz kommt.
**Warum wichtig:** L2 ist die Ebene wo Switches arbeiten, wo MAC-Adressen leben, wo Loops entstehen können (Stichwort STP) — du wirst viel Zeit auf dieser Schicht verbringen.

**Q:** Was macht Layer 3 (Network)?
**A:** Routing und logische Adressierung (IP) — schickt Pakete über Netzwerkgrenzen hinweg.
**Warum wichtig:** L3 ist wo Router arbeiten, wo IP lebt, wo Pakete ihren Weg durch das Internet finden — das Herzstück des Netzwerks.

**Q:** Was macht Layer 4 (Transport)?
**A:** End-to-End Kommunikation zwischen Anwendungen (via Ports), Segmentierung, Flusskontrolle, Fehlerkorrektur (TCP). Protokolle: TCP und UDP.
**Warum wichtig:** L4 entscheidet ob deine Daten zuverlässig ankommen oder nicht — und warum ein Video-Stream anders behandelt wird als ein Datei-Download.

## Netzwerktypen

**Q:** PAN, LAN, MAN, WAN — was ist was?
**A:** PAN = ein Raum (Bluetooth). LAN = Gebäude. MAN = Campus/Stadt. WAN = überregional/weltweit. Reihenfolge nach Größe: PAN < LAN < MAN < WAN.
**Warum wichtig:** Du musst auf Anhieb einordnen können auf welcher Skala ein Netzwerkproblem liegt — ein MAN-Problem löst du anders als ein LAN-Problem.

**Q:** Was ist ein Intranet?
**A:** Privates Netzwerk mit TCP/IP, nicht aus dem Internet erreichbar — technisch ein Mini-Internet, nur intern.
**Warum wichtig:** Viele Firmennetze sind Intranets — du wirst als Engineer oft mit Systemen arbeiten die bewusst nicht aus dem Internet erreichbar sind.

**Q:** Was ist Mesh-Topologie?
**A:** Jeder Knoten ist mit mehreren anderen Knoten direkt verbunden. Hohe Redundanz durch alternative Pfade, aber hoher Verkabelungsaufwand.
**Warum wichtig:** Mesh ist das Prinzip hinter der Robustheit des Internets — fällt ein Knoten aus, gibt es alternative Pfade. Du wirst das auch in modernen Kubernetes-Netzwerken wiedersehen.

## RFCs & Standards

**Q:** Was ist ein RFC?
**A:** Request for Comments — Internetstandard-Dokument, verwaltet von der IETF.
**Warum wichtig:** RFCs sind die Bibel des Internets — wenn du verstehst wie ein Protokoll wirklich funktioniert, liest du den RFC. Als Engineer wirst du früher oder später dort landen.

**Q:** Wann ist ein RFC verbindlich?
**A:** Wenn als "required" gekennzeichnet.
**Warum wichtig:** Nicht jeder RFC ist ein Standard — viele sind informell, experimentell oder veraltet. Das musst du einordnen können wenn du einen RFC zitierst oder umsetzt.

**Q:** Was ist die IETF?
**A:** Internet Engineering Task Force — entwickelt Internetstandards nach "rough consensus and running code".
**Warum wichtig:** Die IETF ist die Organisation hinter den Internetstandards — ihr Motto erklärt warum das Internet pragmatisch statt bürokratisch designed wurde.

## Pakete & Routing

**Q:** Unterschied Weiterleitung vs. Routing?
**A:** Weiterleitung = Paket anhand der Tabelle zum nächsten Hop schicken (Datenpfad). Routing = Tabellen aufbauen und aktualisieren (Kontrollpfad).
**Warum wichtig:** Die meisten verwechseln das. Router machen beides — aber es sind zwei verschiedene Prozesse. Relevant später bei Routing-Protokollen wie OSPF oder BGP.

**Q:** Was steht in einer Weiterleitungstabelle?
**A:** <Ziel, Next_Hop>-Paare — pro Zielnetz der nächste Router.
**Warum wichtig:** Du wirst Weiterleitungstabellen täglich lesen wenn du Netzwerkprobleme debuggst — `netstat -rn` oder `ip route` sind deine ersten Anlaufstellen.

**Q:** Was ist TTL?
**A:** Time to Live — wird pro Hop um 1 reduziert, bei 0 wird Paket verworfen. Verhindert Routing-Schleifen.
**Warum wichtig:** TTL ist dein Schutz gegen Routing-Loops — ohne TTL würde ein falsch geroutetes Paket ewig im Netz kreisen. Du siehst TTL auch bei `traceroute` in Aktion.

**Q:** Was ist Congestion?
**A:** Überlast — mehr Daten als das Netz verarbeiten kann → Puffer füllt sich, Latenz steigt, schließlich Paketverlust.
**Warum wichtig:** Congestion ist einer der Hauptgründe warum das Internet manchmal langsam wird — und TCP hat einen ganzen Mechanismus (Congestion Control) um damit umzugehen.

## IP, DNS, Transport

**Q:** Warum Netzwerkpräfixe statt Hostadressen?
**A:** Skalierbarkeit — Milliarden Hosts, aber nur ~800k Routing-Einträge durch Aggregation. Ein Präfix-Eintrag deckt tausende Hosts ab statt nur einen.
**Warum wichtig:** Das ist der Grund warum das Internet skaliert — ohne Präfixe müsste jeder Router jeden einzelnen Host der Welt kennen. Milliarden Einträge statt ~800k.

**Q:** Was macht DNS?
**A:** Domain Name System — übersetzt Hostnamen → IP-Adressen.
**Warum wichtig:** DNS ist das Telefonbuch des Internets — wenn DNS ausfällt, ist das Internet für normale Nutzer tot, auch wenn die Verbindung technisch funktioniert.

**Q:** TCP vs. UDP?
**A:** TCP = zuverlässig, verbindungsorientiert, geordnete Übertragung (Web, Mail). UDP = schnell, verbindungslos (DNS, Streaming, Gaming).
**Warum wichtig:** Jedes Mal wenn du ein neues Protokoll siehst, fragst du: TCP oder UDP — und warum? Die Antwort bestimmt wie es sich bei Paketverlust verhält.

**Q:** Was ist ein CDN?
**A:** Content Distribution Network — Inhalte auf Edge-Servern nahe am Nutzer repliziert. Ziel: Latenz verringern, Origin-Server entlasten.
**Warum wichtig:** CDNs sind der Grund warum Netflix oder YouTube auch bei Millionen gleichzeitiger Nutzer flüssig läuft — ohne CDN würde jeder Request zum Origin-Server, der würde sofort zusammenbrechen.
