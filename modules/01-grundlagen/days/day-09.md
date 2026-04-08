# Tag 9 — IP, DNS und Transport im Überblick

## Leseauftrag

- **Dordal** Kap. 1.9-1.12 (empfohlen): LANs, IP, DNS, Transport
- **Dordal** Kap. 1.13-1.14 (optional): Firewalls, Dienstprogramme

## Kernkonzepte

- [x] Ethernet: LAN-Technologie, jeder Knoten kann mit jedem kommunizieren
- [x] IP löst das Skalierungsproblem: Milliarden Hosts, aber nur ~800k Routing-Einträge
- [x] IP-Router nutzen Netzwerkpräfixe statt einzelner Hostadressen
- [x] DNS: übersetzt Hostnamen → IP-Adressen
- [x] Transport: TCP (zuverlässig, verbindungsorientiert) vs. UDP (schnell, verbindungslos)
- [x] CDN: Content Distribution Networks — Inhalte nahe am Nutzer repliziert
- [x] Firewalls: Sicherheitsbarriere, oft mit NAT kombiniert

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

### Antworten

**1.** DNS existiert aus drei Gründen:

1. **Usability:** Menschen können sich `google.com` merken, `142.250.185.14` nicht. Namen sind stabil und einprägsam, Zahlen nicht.
2. **IPs können sich ändern, Namen bleiben gleich.** Ein Service kann auf eine neue IP umziehen ohne dass Clients das merken. Im RZ heißt das: Server austauschen, DNS-Name bleibt, keine Konfigurationsänderung beim Client nötig.
3. **Ein Name kann auf mehrere IPs zeigen** (Load Balancing, geografische Verteilung). `google.com` antwortet je nach Standort mit einer anderen IP — unmöglich ohne DNS.

**2.** UDP ist bei **Echtzeit-Anwendungen** besser als TCP: Video-Streaming, VoIP, Online-Gaming, DNS-Abfragen, DHCP.

**Warum:** Bei Echtzeit-Daten ist Aktualität wichtiger als Vollständigkeit. Ein verlorenes Videopaket? Kurzer Bildfehler, kaum merkbar. Eine TCP-Retransmit-Verzögerung? Das Video ruckelt sichtbar. TCP würde verlorene Pakete nachliefern — aber bis die Retransmits ankommen, ist der Moment im Stream schon vorbei. UDP ignoriert Verluste und läuft einfach weiter.

Weitere UDP-Fälle: **DNS** (klein, schnell, bei Verlust einfach nochmal fragen), **DHCP** (läuft per Broadcast bevor der Client überhaupt eine IP hat — TCP wäre hier gar nicht möglich).

**3.** Ein CDN (Content Distribution Network) cached Inhalte auf Edge-Servern nahe am Nutzer. Drei Performance-Vorteile:

1. **Geringere Latenz** — der Edge-Server ist physisch näher, kürzere Wege = weniger Millisekunden. Wichtigster Faktor.
2. **Weniger Last auf dem Origin-Server** — bei 1000 gleichen Requests geht nur einer bis zum Ursprung, der Rest kommt aus dem Edge-Cache.
3. **Ausfallsicherheit** — fällt der Origin aus, kann der Edge oft noch gecachte Inhalte ausliefern.

Im eigenen Traceroute sichtbar: `1.1.1.1` wurde nur 9 Hops über einen Cloudflare-Edge in der Region beantwortet — nicht quer durchs Netz zum echten Cloudflare-Datacenter.

## RZ-Relevanz

- **DNS-Ausfälle = Totalausfall gefühlt.** Wenn der interne DNS-Resolver nicht antwortet, sehen Clients "Service nicht erreichbar", obwohl der eigentliche Service läuft. DNS-Monitoring ist deshalb Pflicht.
- **Kurze DNS-TTLs bei Deployments:** Vor einem IP-Wechsel (z.B. Server-Migration) setzt man die TTL des DNS-Eintrags auf wenige Sekunden runter, damit Clients die neue IP schnell lernen. Standard-TTL ist oft 1h+.
- **TCP vs. UDP im Monitoring:** Ein UDP-Service (DNS, NTP, SNMP) "funktioniert" aus TCP-Sicht nie — Port-Scans per TCP finden ihn nicht. Man braucht protokollspezifische Checks (`dig`, `ntpq`, `snmpget`).
- **Firewall-Regeln auf Port-Basis greifen nur für TCP/UDP-Traffic.** ICMP (Ping) läuft darunter — deshalb kann Ping erlaubt sein während ein Service geblockt ist. Das hast du in Tag 6 bereits erlebt.
- **CDN-Caching kann bei Deployments trügen:** Nach einem Deploy sehen Nutzer manchmal noch die alte Version, weil der CDN-Edge noch den alten Inhalt cached. "Cache purgen" ist eine Standard-Deploy-Aufgabe.
- **Routing-Aggregation ist der Grund warum das Internet überhaupt funktioniert:** Ohne Präfix-Zusammenfassung hätten Backbone-Router Milliarden Einträge statt ~800k. Jedes IP-Subnetting-Konzept baut darauf auf.
