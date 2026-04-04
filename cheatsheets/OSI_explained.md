# OSI-Modell — erklärt als Postweg

## Die 7 Schichten

### Schicht 7 — Anwendung (Application)
Du diktierst den Brief deiner Sekretärin:
"Schreib mal an Firma Müller wegen der Rechnung."
= Was will ich kommunizieren?

**= HTTP, DNS, SSH**

### Schicht 6 — Darstellung (Presentation)
Die Sekretärin formatiert den Brief:
Deutsch oder Englisch? PDF oder Fax? Verschlüsselt?
Sie übersetzt deine Absicht in ein lesbares Format.

**= TLS/SSL, JPEG, UTF-8**

### Schicht 5 — Sitzung (Session)
Die Sekretärin führt ein Gesprächsprotokoll:
"Das ist Brief 3 in unserer laufenden Korrespondenz mit Firma Müller."
Sie merkt sich, dass ein Dialog läuft, und ordnet Antworten zu.

**= Session-Management, Tokens**

### Schicht 4 — Transport
Der Brief kommt in den Umschlag.
"An: Abteilung Buchhaltung" (= Port), Seite 1 von 3 (= Sequenz).
Einschreiben mit Rückschein (= TCP) oder Postkarte (= UDP).

**= TCP, UDP**

### Schicht 3 — Vermittlung (Network)
Die Post liest die Adresse: "Musterstraße 5, Berlin" (= IP).
Jede Sortierstation entscheidet den nächsten Hop.

**= IP, ICMP, Router**

### Schicht 2 — Sicherung (Data Link)
Der Briefträger vor Ort:
"Welcher Briefkasten in dieser Straße?" (= MAC).
Prüft ob der Brief beschädigt ist (= Prüfsumme/CRC).

**= Ethernet, ARP, Switch**

### Schicht 1 — Bitübertragung (Physical)
Das Transportmittel selbst:
Postauto, Fahrrad, Drohne (= Kabel, WLAN, Glasfaser).
Nicht WAS transportiert wird, sondern WIE — Geschwindigkeit,
Straßenbreite, ob asphaltiert oder Feldweg.

**= Signale, Stecker, Kabel, Frequenzen**

## TCP/IP vs. OSI — was wurde zusammengefasst?

```
OSI                          TCP/IP           Post-Analogie
┌─ 7 Anwendung  ─┐
│  6 Darstellung  │  →  4 Anwendung    →  Brief diktieren + formatieren
└─ 5 Sitzung    ─┘                        + Gesprächsprotokoll führen

   4 Transport      →  3 Transport    →  Umschlag + Einschreiben

   3 Vermittlung    →  2 Internet     →  Postadresse + Sortierstation

┌─ 2 Sicherung  ─┐
└─ 1 Bitübertrag.─┘ →  1 Netzzugang  →  Briefträger + Transportmittel
```

## Schlüsselbegriffe

| Postweg | Netzwerk | Schicht |
|---------|----------|---------|
| Brief diktieren | Anwendungsdaten | 7 Anwendung |
| Brief formatieren/übersetzen | Kodierung, Verschlüsselung | 6 Darstellung |
| Gesprächsprotokoll führen | Session-ID, Tokens | 5 Sitzung |
| Umschlag + "Abt. Buchhaltung" | TCP/UDP + Port | 4 Transport |
| Adresse auf dem Umschlag | IP-Adresse | 3 Vermittlung |
| Name am Briefkasten + Zustandsprüfung | MAC-Adresse + CRC | 2 Sicherung |
| Postauto / Fahrrad / Drohne | Kabel / WLAN / Glasfaser | 1 Bitübertragung |
