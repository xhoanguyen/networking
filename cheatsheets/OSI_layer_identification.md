# Welche OSI-Schicht? So findest du die Antwort

## Die Regel

Finde die **Heimat-Schicht** des Protokolls → alles darunter ist beteiligt, alles darüber nicht.

## Beispiele

```
ARP = Schicht 2       → braucht Schicht 2, 1
Ping (ICMP) = Schicht 3  → braucht Schicht 3, 2, 1
SSH = Schicht 7       → braucht alle 7
HTTP = Schicht 7      → braucht alle 7
```

## Schnelltest: 3 Fragen

```
1. Braucht es einen Port?
   Nein → maximal Schicht 3
   Ja   → mindestens Schicht 4

2. Braucht es TCP oder UDP?
   Nein → maximal Schicht 3 (z.B. ICMP, ARP)
   Ja   → mindestens Schicht 4

3. Gibt es Anwendungsdaten (HTML, DNS-Record, E-Mail)?
   Nein → bleibt bei Schicht 3 oder 4
   Ja   → Schicht 7
```

## Warum ist Ping nicht Schicht 7?

Ping ist kein Programm das Daten an eine Anwendung schickt.
Es fragt nur: "Bist du da?" — eine reine Netzwerk-Frage (Schicht 3).

- Kein Port → keine Schicht 4
- Keine Session → keine Schicht 5
- Kein Datenformat → keine Schicht 6
- Keine Anwendungsdaten → keine Schicht 7

ICMP-Pakete werden direkt in IP-Pakete verpackt — sie überspringen TCP/UDP komplett.

## Häufige Protokolle und ihre Heimat-Schicht

| Protokoll | Schicht | Warum? |
|-----------|---------|--------|
| ARP | 2 | Fragt nur nach MAC-Adressen, braucht keine IP |
| ICMP (Ping) | 3 | Netzwerk-Diagnose, kein Port, kein TCP/UDP |
| TCP / UDP | 4 | Transport mit Ports und Sequenznummern |
| HTTP / HTTPS | 7 | Überträgt Webseiten-Inhalte |
| DNS | 7 | Überträgt Anwendungsdaten (Name → IP), nutzt UDP auf Schicht 4 |
| SSH | 7 | Terminal-Session mit Anwendungsdaten |
| DHCP | 7 | Vergibt IP-Adressen, nutzt UDP auf Schicht 4 |
