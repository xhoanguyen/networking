# Tag 9 — IP, DNS und Transport im Überblick

## Leseauftrag

- **Dordal** Kap. 1.9-1.12 (empfohlen): LANs, IP, DNS, Transport
- **Dordal** Kap. 1.13-1.14 (optional): Firewalls, Dienstprogramme

## Kernkonzepte

- [ ] Ethernet: LAN-Technologie, jeder Knoten kann mit jedem kommunizieren
- [ ] IP löst das Skalierungsproblem: Milliarden Hosts, aber nur ~800k Routing-Einträge
- [ ] IP-Router nutzen Netzwerkpräfixe statt einzelner Hostadressen
- [ ] DNS: übersetzt Hostnamen → IP-Adressen
- [ ] Transport: TCP (zuverlässig, verbindungsorientiert) vs. UDP (schnell, verbindungslos)
- [ ] CDN: Content Distribution Networks — Inhalte nahe am Nutzer repliziert
- [ ] Firewalls: Sicherheitsbarriere, oft mit NAT kombiniert

## Flashcards

**Q:** Warum nutzen IP-Router Netzwerkpräfixe statt einzelner Hostadressen?
**A:** Skalierbarkeit — es gibt Milliarden von Hosts, aber die Routing-Tabelle im Backbone hat nur ~800.000 Einträge. Durch Präfixe (z.B. 192.168.1.0/24) werden ganze Netze zusammengefasst.

**Q:** Was macht DNS?
**A:** Domain Name System — übersetzt menschenlesbare Hostnamen (z.B. google.com) in IP-Adressen (z.B. 142.250.185.14). Erlaubt Diensten, ihre IP zu ändern ohne Nutzer zu benachrichtigen.

**Q:** TCP vs. UDP — wann was?
**A:** TCP: zuverlässig, verbindungsorientiert, mit Bestätigung (Web, E-Mail, SSH). UDP: schnell, verbindungslos, ohne Bestätigung (DNS-Abfragen, Streaming, Gaming).

**Q:** Was ist ein CDN?
**A:** Content Distribution Network — Inhalte werden in Edge-Servern nahe am Nutzer repliziert, um Latenz zu reduzieren. Beispiele: Cloudflare, Akamai, AWS CloudFront.

## Mini-Quiz

1. Warum braucht man DNS, wenn Computer eigentlich nur mit IP-Adressen arbeiten?
2. Für welche Anwendung wäre UDP besser geeignet als TCP — und warum?
3. Wie hilft ein CDN bei der Performance einer Website?
