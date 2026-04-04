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

## Wo wird die Adresse hinzugefügt?

Die Adresse wird nicht auf einmal draufgeschrieben — jede Schicht fügt ihren Teil hinzu:

```
Schicht 3 — Vermittlung:  Ziel-IP auf den Umschlag (= Endziel, bleibt immer gleich)
Schicht 2 — Sicherung:    Ziel-MAC als lokales Etikett (= nächster Briefkasten, ändert sich pro Hop)
```

Im echten Leben schreibst du die Adresse selbst auf den Brief (= alles in der Anwendung).
Im Netzwerk kennt die Anwendung nur das Ziel — die unteren Schichten
kümmern sich um IP und MAC, ohne den Inhalt zu kennen.

## Encapsulation — Puppe in Puppe (Matrjoschka)

Jede Schicht verpackt die Daten der darüberliegenden Schicht in einen
neuen Umschlag — ohne den Inhalt zu kennen:

```
[Ethernet-Header [IP-Header [TCP-Header [HTTP-Daten]]]]
      ↑               ↑           ↑          ↑
  Schicht 2       Schicht 3   Schicht 4   Schicht 7
  MAC-Adressen    IP-Adressen Ports       Dein Request
```

Die bessere Post-Analogie: Du diktierst den Brief (Schicht 7), gibst ihn
der Sekretärin (Schicht 6-5), die gibt ihn der Poststelle (Schicht 4),
die gibt ihn der Logistik (Schicht 3), die gibt ihn dem Briefträger
(Schicht 2-1) — und keiner öffnet den Umschlag des anderen.

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
