# Lab 10 — Das große Bild zusammensetzen

**Datum:** 2026-04-10
**Ziel:** Den Weg eines Pakets durch alle OSI-Schichten nachvollziehen.

---

## Schritt 1: DNS-Auflösung — `dig example.com`

```
; <<>> DiG 9.10.6 <<>> example.com
;; ANSWER SECTION:
example.com.        172    IN    A    172.66.147.243
example.com.        172    IN    A    104.20.23.154

;; Query time: 13 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
```

**Beobachtungen:**
- DNS-Server: eigener Router `192.168.1.1` (lokaler Resolver)
- Zwei IPs zurück → example.com liegt hinter Cloudflare CDN (Load Balancing)
- TTL: 172s → Antwort war im Cache des Routers
- Query time: 13ms → sehr schnell dank Cache

**OSI-Einordnung:**
| Schicht | Was passiert |
|---------|-------------|
| L7 Application | DNS-Protokoll, Name → IP Auflösung |
| L4 Transport | UDP, Port 53 |
| L3 Network | Laptop → Router (192.168.1.1) |

---

## Schritt 2: Route verfolgen — `traceroute example.com`

```
traceroute to example.com (104.20.23.154), 64 hops max
 1  funbox (192.168.1.1)          4ms
 2  poz-bng5.neo.tpnet.pl         11ms   ← ISP (tpnet.pl, Poznań)
 3  poz-r11/r22.tpnet.pl          10ms   ← ISP-internes Routing, Load Balancing
 4  war-r21.tpnet.pl              14ms   ← Warschau, ein Probe ohne Antwort (*)
 5  217.98.245.54                 15ms   ← anonymer Transit-Router
 6  akamai.gw.opentransit.net     15ms   ← Übergabe an CDN-Netz
 7  162.158.100.x                 16ms   ← Cloudflare Edge, Anycast
 8  104.20.23.154                 15ms   ← Ziel erreicht (Cloudflare)
```

**Beobachtungen:**
- Nur 8 Hops bis zum Ziel → Cloudflare sitzt sehr nah (CDN in Aktion)
- Hop 3 + 7: verschiedene IPs auf dieselbe Anfrage → Load Balancing / Anycast
- `*` bei Hop 4: Router antwortet nicht auf ICMP → normal, kein Fehler
- Übergabe an Cloudflare bei Hop 6

**OSI-Einordnung:**
| Schicht | Was passiert |
|---------|-------------|
| L3 Network | jeder Hop = Router leitet Paket weiter |
| L3 Network | TTL wird pro Hop um 1 reduziert — traceroute nutzt das gezielt |

---

## Schritt 3: HTTP-Verbindung — `curl -v http://example.com`

```
* Host example.com:80 was resolved.
* IPv4: 172.66.147.243, 104.20.23.154
*   Trying 172.66.147.243:80...
* Connected to example.com (172.66.147.243) port 80
> GET / HTTP/1.1
> Host: example.com
> User-Agent: curl/8.7.1
> Accept: */*
< HTTP/1.1 200 OK
< Server: cloudflare
< Content-Type: text/html
< Connection: keep-alive
```

**Beobachtungen:**
- DNS bereits aufgelöst → zwei IPs verfügbar, curl wählt `172.66.147.243`
- TCP-Verbindung auf Port 80 → Handshake erfolgreich (L4)
- HTTP GET Request → L7, Anwendungsprotokoll
- `200 OK` → Server hat geantwortet
- `Server: cloudflare` → bestätigt CDN
- `Connection: keep-alive` → TCP-Verbindung bleibt offen für weitere Requests
- curl wählte andere IP als traceroute → Anycast, beide sind Cloudflare Edge-Server

**OSI-Einordnung:**
| Schicht | Was passiert |
|---------|-------------|
| L7 Application | HTTP GET Request, Antwort 200 OK |
| L4 Transport | TCP, Port 80, Handshake, keep-alive |
| L3 Network | IP-Routing zu 172.66.147.243 |

---

## Paketweg-Zusammenfassung

```
Laptop
  │  L7: DNS-Anfrage → "Was ist die IP von example.com?"
  │  L4: UDP, Port 53
  ▼
Router (192.168.1.1)
  │  Antwort: 172.66.147.243, 104.20.23.154
  │
  │  L7: HTTP GET /
  │  L4: TCP, Port 80 — Handshake
  │  L3: IP-Routing, TTL wird pro Hop reduziert
  │  L2: MAC-Adresse des Routers (Gateway)
  │  L1: WLAN-Interface (en0)
  ▼
ISP (tpnet.pl, Poznań)
  ▼
Warschau → Transit
  ▼
Cloudflare Edge (8 Hops, ~15ms)
  ▼
104.20.23.154 / 172.66.147.243 → HTTP 200 OK
```

---

## OSI-Gesamtübersicht

| Schicht | Was passiert bei einer HTTP-Anfrage zu example.com |
|---------|-----------------------------------------------------|
| L7 Application | DNS-Auflösung (Name → IP), HTTP GET Request, 200 OK |
| L4 Transport | TCP Port 80, Handshake, keep-alive; UDP Port 53 für DNS |
| L3 Network | IP-Routing über 8 Hops, TTL-Dekrement pro Hop |
| L2 Data Link | MAC-Adresse des Gateways (Router) für lokale Übertragung |
| L1 Physical | WLAN-Interface (en0) |

---

## Reflexion

### Erkenntnisse aus dem Lab

1. **dig** ist das Go-To-Tool bei DNS-Problemen — gezielte Abfragen, TTL sichtbar, DNS-Server wählbar
2. **curl -v** macht die OSI-Schichten sichtbar — TCP-Handshake (L4) und HTTP-Request (L7) direkt lesbar, obwohl man curl täglich nutzt
3. **traceroute** zeigt den Weg des Pakets — aber nur in eine Richtung, der Rückweg kann komplett anders verlaufen (Asymmetric Routing)

### Sicherheits-Exkurs: Wer sieht mich im Netz?

**Jedes IP-Paket enthält Source IP + Destination IP** — der Server sieht immer wer ihm schreibt.

Was der Zielserver sieht:
- Öffentliche IP (die des Routers, nicht des Laptops — NAT versteckt die private IP)
- ISP und ungefährer Standort
- User-Agent (z.B. `curl/8.7.1` oder Browser-Version)

Was er nicht sieht:
- Private IP hinter dem Router
- Den vollständigen Rückweg (Asymmetric Routing)

### Das VPN-Paradox

VPN ersetzt deine IP durch die des VPN-Servers — Cloudflare sieht nur den VPN, nicht dich.
Aber: **der VPN-Anbieter sieht alles was Cloudflare vorher sah.** Das Problem ist nur verschoben, nicht gelöst.

Viele "No-Log VPNs" haben trotzdem Logs herausgegeben wenn Behörden gefragt haben.

### Echte Anonymität: Tor-Prinzip

Tor löst das Problem durch **drei unabhängige Relays**:

```
Du → Relay 1 → Relay 2 → Relay 3 → Ziel

Relay 1: weiß wer du bist, aber nicht wohin
Relay 3: weiß wohin, aber nicht wer du bist
Keiner kennt den vollständigen Weg
```

Auch Tor ist nicht perfekt — Timing-Angriffe, kompromittierte Exit-Nodes, Metadaten.

**Fazit:** Echte Anonymität im Netz ist extrem schwer. Meistens geht es nur darum, wie viel Aufwand jemand betreiben muss um dich zu identifizieren.
