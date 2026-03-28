# Tag 10 — Wochenend-Review + Modul-Abschluss (Sa/So)

## Wiederholung (20 Min)

Geh ALLE Flashcards von Tag 1-9 durch. Sortiere in drei Stapel:
- **Sicher:** Antwort sofort gewusst
- **Wackelig:** Musste nachdenken
- **Unsicher:** Antwort nicht gewusst → diese nächste Woche nochmal wiederholen

## Gesamtquiz Modul 01

Beantworte ohne nachzuschlagen:

1. Nenne die 7 OSI-Schichten.
2. Nenne die 4 TCP/IP-Schichten.
3. Was ist der Unterschied zwischen Weiterleitung und Routing?
4. Was bedeutet TTL und warum ist es wichtig?
5. Erkläre den Unterschied zwischen TCP und UDP.
6. Was ist ein RFC und wann ist er verbindlich?
7. Ordne zu: PAN, LAN, MAN, WAN — Bluetooth-Kopfhörer / Büronetz / Campus / Internet
8. Was macht DNS?
9. Was steht in einer Weiterleitungstabelle?
10. Warum setzte sich TCP/IP gegen das OSI-Modell durch?

> Überprüfe deine Antworten anhand der Flashcards und Buchstellen.

## Lab: Das große Bild zusammensetzen

**Ziel:** Den Weg eines Pakets durch alle Schichten nachvollziehen.

### Aufgabe: Verfolge eine HTTP-Anfrage

```bash
# 1. DNS-Auflösung beobachten
dig example.com

# 2. Route zum Server verfolgen
traceroute example.com

# 3. HTTP-Verbindung aufbauen (TCP)
curl -v http://example.com 2>&1 | head -20
```

**Dokumentiere für jede Schicht:**
- [ ] **Application (L7):** Was passiert? (HTTP GET Request)
- [ ] **Transport (L4):** Welches Protokoll? (TCP, Port 80)
- [ ] **Network (L3):** Welche IP-Adressen? (Quelle → Ziel)
- [ ] **Data Link (L2):** Welche MAC-Adresse wird genutzt? (Gateway)
- [ ] **Physical (L1):** Über welches Interface? (en0/en1)

### Aufgabe: Zeichne den Paketweg

Zeichne (auf Papier oder digital) den Weg eines Pakets von deinem Laptop zu example.com:
1. Dein Laptop → Router (Gateway)
2. Router → ISP
3. ISP → ... → Zielserver

Beschrifte jede Station mit der OSI-Schicht, die dort relevant ist.

## Reflexion

- [ ] Was war das schwierigste Konzept diese Woche?
- [ ] Welche Flashcards muss ich nächste Woche wiederholen?
- [ ] Was möchte ich im nächsten Modul (Netzwerktechnik) besonders verstehen?
