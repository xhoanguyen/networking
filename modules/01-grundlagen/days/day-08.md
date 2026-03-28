# Tag 8 — Pakete, Weiterleitung und Routing

## Leseauftrag

- **Dordal** Kap. 1.3-1.4 (empfohlen): Pakete und Datagrammweiterleitung
- **Dordal** Kap. 1.6-1.7 (optional): Routing-Schleifen und Überlast

## Kernkonzepte

- [ ] Paketaufbau: Header (Zustellinfos) + Payload (Nutzdaten)
- [ ] Weiterleitungstabelle: <Ziel, Next_Hop>-Paare
- [ ] Jeder Router kennt nur den nächsten Schritt (Hop), nicht den ganzen Weg
- [ ] Weiterleitung vs. Routing: Weiterleitung = Paket transportieren, Routing = Tabellen aufbauen
- [ ] Routing-Schleifen: Pakete kreisen endlos — muss verhindert werden (z.B. TTL)
- [ ] Überlast (Congestion): Netz signalisiert, dass max. Rate erreicht ist

## Flashcards

**Q:** Was ist der Unterschied zwischen Weiterleitung (Forwarding) und Routing?
**A:** Weiterleitung = der Prozess, ein Paket basierend auf der Tabelle zum nächsten Hop zu schicken. Routing = die Algorithmen, die die Weiterleitungstabellen aufbauen und aktualisieren.

**Q:** Was steht in einer Weiterleitungstabelle?
**A:** Paare aus <Ziel, Next_Hop> — für jedes Zielnetz wird angegeben, an welchen nächsten Router das Paket geschickt werden soll.

**Q:** Was ist eine Routing-Schleife und wie wird sie verhindert?
**A:** Pakete kreisen endlos zwischen Routern. Verhindert durch TTL (Time to Live) im IP-Header — wird bei jedem Hop um 1 reduziert, bei 0 wird das Paket verworfen.

**Q:** Was ist Congestion (Überlast)?
**A:** Der Zustand, wenn mehr Daten ins Netz geschickt werden als es verarbeiten kann. Führt zu Paketverlust und erhöhter Latenz.

## Mini-Quiz

1. Ein Paket hat TTL=3 und muss 5 Hops passieren — was passiert?
2. Warum kennt ein Router nicht den kompletten Pfad eines Pakets?
3. Was passiert bei Congestion mit den Paketen in der Warteschlange eines Routers?
