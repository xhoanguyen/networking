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

## MAC-Adresse ändert sich, IP bleibt gleich

In jeder Stadt wird der Brief in einen neuen lokalen Umschlag gesteckt.
Die IP-Adresse (Stadt+Straße) bleibt gleich, aber die MAC-Adresse
(Briefkasten) ändert sich bei jedem Hop — weil der Briefträger vor Ort
immer nur den nächsten Briefkasten kennt.

## Wo wird die Adresse hinzugefügt?

Die Adresse wird nicht auf einmal draufgeschrieben. Jede Schicht fügt ihren Teil hinzu:

```
Schicht 2 — Internet:    Ziel-IP auf den Umschlag (= Endziel, bleibt immer gleich)
Schicht 1 — Netzzugang:  Ziel-MAC als lokales Etikett (= nächster Briefkasten, ändert sich pro Hop)
```

Beispiel: Mac (192.168.1.48) → Google (8.8.8.8):

```
Hop 1: Mac → Router
        Ziel-IP:  8.8.8.8              (bleibt gleich)
        Ziel-MAC: e4:c0:e2:56:cc:b0    (MAC des Routers)

Hop 2: Router → ISP
        Ziel-IP:  8.8.8.8              (bleibt gleich)
        Ziel-MAC: aa:bb:cc:dd:ee:ff     (MAC des ISP-Routers)

Hop 3: ISP → Google
        Ziel-IP:  8.8.8.8              (bleibt gleich)
        Ziel-MAC: 11:22:33:44:55:66     (MAC des Google-Servers)
```

## Encapsulation (Puppe in Puppe / Matrjoschka)

Im echten Leben schreibt man Adresse + Inhalt auf einmal. Im Netzwerk
verpackt jede Schicht die Daten der darüberliegenden Schicht in einen
neuen Umschlag, ohne den Inhalt zu kennen:

```
[Ethernet-Header [IP-Header [TCP-Header [HTTP-Daten]]]]
      ↑               ↑           ↑          ↑
  Schicht 1       Schicht 2   Schicht 3   Schicht 4
  MAC-Adressen    IP-Adressen Ports       Dein Request
```

Du diktierst den Brief (Anwendung), gibst ihn der Poststelle (Transport),
die gibt ihn der Logistik (Internet), die gibt ihn dem Briefträger (Netzzugang)
— und keiner öffnet den Umschlag des anderen.

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
