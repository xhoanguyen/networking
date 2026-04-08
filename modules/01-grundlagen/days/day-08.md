# Tag 8 — Pakete, Weiterleitung und Routing

## Leseauftrag

- **Dordal** Kap. 1.3-1.4 (empfohlen): Pakete und Datagrammweiterleitung
- **Dordal** Kap. 1.6-1.7 (optional): Routing-Schleifen und Überlast

## Kernkonzepte

- [x] Paketaufbau: Header (Zustellinfos) + Payload (Nutzdaten)
- [x] Weiterleitungstabelle: <Ziel, Next_Hop>-Paare
- [x] Jeder Router kennt nur den nächsten Schritt (Hop), nicht den ganzen Weg
- [x] Weiterleitung vs. Routing: Weiterleitung = Paket transportieren, Routing = Tabellen aufbauen
- [x] Routing-Schleifen: Pakete kreisen endlos — muss verhindert werden (z.B. TTL)
- [x] Überlast (Congestion): Netz signalisiert, dass max. Rate erreicht ist

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

### Antworten

**1.** Nach jedem Hop wird der TTL-Wert um 1 reduziert. Bei TTL=3 passiert also:

- Hop 1: TTL 3 → 2
- Hop 2: TTL 2 → 1
- Hop 3: TTL 1 → 0 → **Router verwirft das Paket**

Der verwerfende Router schickt eine ICMP-Nachricht **"Time Exceeded"** an den Absender zurück. Genau dieser Mechanismus wird von `traceroute` ausgenutzt: es sendet absichtlich Pakete mit TTL=1, 2, 3, ... und sammelt die "Time Exceeded"-Antworten ein — so wird der Pfad Hop für Hop sichtbar.

**2.** Zwei Gründe:

1. **Skalierung:** Das Internet hat Milliarden von Geräten — unmöglich, vollständige Pfade zu jedem Ziel zu speichern. Router speichern nur Ziel-**Netze** (z.B. `10.0.5.0/24`) und den zugehörigen Next Hop.
2. **Dynamik:** In paketvermittelten Netzen können Pakete derselben Verbindung verschiedene Wege nehmen (Load Balancing, z.B. bei Cloudflare sichtbar als zwei IPs `162.158.100.67/.61` im Traceroute). Pfade ändern sich außerdem ständig, wenn Links ausfallen.

Jeder Router trifft nur eine lokale Entscheidung: "Für dieses Ziel-Netz → an diesen Next Hop." Der Gesamtpfad entsteht schrittweise, ohne dass ein einzelner Router ihn kennt.

**3.** Bevor die Queue komplett voll ist, **steigt zuerst die Latenz**, weil Pakete in der Warteschlange warten müssen. Ist die Queue voll, werden neue Pakete **verworfen** (Paketverlust, "tail drop").

**TCP reagiert automatisch** auf Paketverlust und drosselt die Senderate (**Congestion Control**) — deshalb werden TCP-Verbindungen bei Überlast langsamer, brechen aber nicht zusammen. **UDP macht das nicht** — ein UDP-Stream (Video, VoIP) sendet einfach weiter und verliert Pakete.

## RZ-Relevanz

- **Traceroute ist dein Diagnose-Werkzeug Nr. 1 bei Routing-Problemen.** Wenn ein Server nicht erreichbar ist, zeigt dir Traceroute, an welchem Hop der Pfad abbricht — oft genug ist es ein falsch konfigurierter Router oder eine ACL, die ein Zwischennetz blockiert.
- **Load Balancing erkennen:** Wenn im Traceroute an derselben Hop-Nummer mehrere IPs erscheinen (wie bei Cloudflare in deinem Lab), siehst du Equal-Cost Multi-Path Routing — der Router verteilt Traffic über mehrere gleich gute Pfade. Das ist bei Leaf-Spine-Architekturen im RZ Standard.
- **Congestion im Monitoring erkennen:** Steigende Latenz **plus** Paketverlust auf einem Interface ist ein klassisches Congestion-Symptom — nicht unbedingt ein Hardware-Defekt. Typisches Beispiel: Backup-Job nachts zieht die volle Bandbreite, Monitoring-Alerts kommen verzögert an.
- **TTL-Anomalien sind ein Warnsignal:** Wenn du plötzlich ungewöhnlich hohe Hop-Zahlen zu einem Ziel siehst, das vorher nah war, hat sich ein Routing-Pfad geändert — z.B. weil ein Upstream-Link ausgefallen ist und BGP umgeroutet hat.
- **Default Route (`0.0.0.0/0`) ist die letzte Instanz:** Jeder Router im RZ hat sie — "alles was ich nicht kenne, gib an den Upstream." Fehlt sie oder zeigt falsch, gehen Pakete ins Leere.
