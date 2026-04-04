# TCP/IP-Modell — erklärt als Postweg

## Die 4 Schichten

### Schicht 4 — Anwendung
Du schreibst einen Brief (den Inhalt).
Sprache, Format, Anrede — das ist alles Anwendungssache.

**= HTTP, DNS, SSH**

### Schicht 3 — Transport
Du steckst den Brief in einen Umschlag.
Drauf schreibst du: "An Abteilung Buchhaltung" (= Port).
Und eine Nummer, damit die Antwort zugeordnet werden kann.
Bei einem langen Brief nummerierst du die Seiten,
damit der Empfänger sie in der richtigen Reihenfolge liest (= TCP).
Oder du schickst eine Postkarte ohne Rückmeldung (= UDP).

**= TCP, UDP**

### Schicht 2 — Internet
Die Post schaut auf die Adresse:
"Musterstraße 5, 10115 Berlin" (= Ziel-IP).
Sie plant die Route: Berlin → München → Zürich.
Jede Sortierstation (= Router) entscheidet nur den nächsten Hop.

**= IP, ICMP**

### Schicht 1 — Netzzugang
Der Briefträger vor Ort. Er kennt keine Städte, nur:
"Welcher Briefkasten in DIESER Straße?" (= MAC-Adresse).
Er nimmt den Brief und steckt ihn physisch rein —
ob zu Fuß, per Fahrrad oder Auto (= Kabel, WLAN, Glasfaser).

**= Ethernet, ARP, WLAN**

## Der komplette Weg eines Pakets

```
Du (App) schreibst einen Brief                    ← Anwendung
Steckst ihn in Umschlag, "An: Buchhaltung, S.1/3" ← Transport
Post liest Adresse, plant Route über 5 Städte      ← Internet
Briefträger in jeder Stadt: "Welcher Briefkasten?"  ← Netzzugang
```

## Wichtig: MAC-Adresse ändert sich, IP bleibt gleich

In jeder Stadt wird der Brief in einen neuen lokalen Umschlag gesteckt.
Die IP-Adresse (Stadt+Straße) bleibt gleich, aber die MAC-Adresse
(Briefkasten) ändert sich bei jedem Hop — weil der Briefträger vor Ort
immer nur den nächsten Briefkasten kennt.

## Schlüsselbegriffe

| Postweg | Netzwerk | Schicht |
|---------|----------|---------|
| Briefinhalt | Daten (HTML, JSON) | Anwendung |
| Umschlag + "Abt. Buchhaltung" | TCP/UDP + Port | Transport |
| Adresse auf dem Umschlag | IP-Adresse | Internet |
| Name am Briefkasten | MAC-Adresse | Netzzugang |
| Sortierstation | Router | Internet |
| Briefträger vor Ort | Switch / ARP | Netzzugang |
| Brief in neuen Umschlag stecken | Frame neu verpacken (neuer Ethernet-Header) | Netzzugang |
