# Tag 2 — TCP/IP: Die Protokollfamilie

## Leseauftrag

- **Zisler** Kap. 1.2 (S. 23): Die Netzwerkprotokollfamilie TCP/IP
- **Dordal** Kap. 1.16 (optional): Berkeley Unix und die Geschichte von TCP/IP

## Kernkonzepte

- [x] TCP/IP: Entstehung aus dem ARPA-Projekt (70er-Jahre)
- [x] Durchbruch durch 4.2BSD (Berkeley Unix)
- [x] Architekturunabhängigkeit: läuft auf jeder Hardware
- [x] Offene Standards: frei zugänglich, nicht proprietär
- [x] TCP = Transmission Control Protocol, IP = Internet Protocol

## Flashcards

**Q:** Wann und wo entstand TCP/IP?
**A:** In den 1970er-Jahren im Rahmen des ARPA-Projekts (US-Verteidigungsministerium). Der Durchbruch kam durch die Implementierung in 4.2BSD (Berkeley Unix).

**Q:** Warum setzte sich TCP/IP gegenüber anderen Protokollen durch?
**A:** Architekturunabhängig (läuft auf jeder Hardware), offene/frei zugängliche Standards, und praktische Referenzimplementierung in BSD Unix.

**Q:** Was bedeutet "architekturunabhängig" bei TCP/IP?
**A:** Die Protokolle sind nicht an eine bestimmte Hardware oder ein Betriebssystem gebunden — sie funktionieren auf PCs, Macs, Linux-Servern, Smartphones, IoT-Geräten etc.

## Mini-Quiz

### 1. Was war 4.2BSD und warum war es wichtig für TCP/IP?

**Antwort:** 4.2BSD (Berkeley Software Distribution) war ein Unix-Derivat, das 1983 an der University of California, Berkeley, veröffentlicht wurde. Es war die **erste Betriebssystem-Distribution, die TCP/IP direkt eingebaut** hatte — als feste Komponente des Netzwerk-Stacks.

Entscheidend war die Kombination aus zwei Faktoren:
- **Frei zugänglich:** 4.2BSD wurde an Universitäten massiv verbreitet. Studierende und Forscher lernten TCP/IP direkt im Studium kennen und nahmen dieses Wissen in die Industrie mit.
- **Referenzimplementierung:** Die BSD-Implementierung wurde zum De-facto-Standard. Viele spätere TCP/IP-Stacks (auch kommerzielle) basieren auf oder orientierten sich an der BSD-Implementierung.

Ohne 4.2BSD wäre TCP/IP möglicherweise ein akademisches Protokoll geblieben — die freie Verfügbarkeit einer funktionierenden Implementierung war der entscheidende Netzwerkeffekt für die Verbreitung.

> **Quellen:** Zisler Kap. 1.2 (S. 23), Dordal Kap. 1.16

> **RZ-Relevanz:** Dieses Muster — offener Standard + freie Referenzimplementierung = Massenverbreitung — wiederholt sich im RZ-Umfeld ständig. Kubernetes selbst folgt genau diesem Prinzip: Google hat es als Open-Source-Projekt veröffentlicht, die Community hat es übernommen, und heute ist es der Standard für Container-Orchestrierung. Auch die Container-Networking-Spezifikation (CNI) ist ein offener Standard, den verschiedene Implementierungen (Calico, Cilium, Flannel) umsetzen.

---

### 2. Was unterscheidet offene Standards von proprietären Protokollen?

**Antwort:**

| | Offene Standards | Proprietäre Protokolle |
|---|---|---|
| **Spezifikation** | Frei zugänglich (z.B. RFCs) | Nicht öffentlich, nur beim Hersteller |
| **Implementierung** | Jeder kann eine eigene bauen | Nur der Hersteller |
| **Kosten** | Keine Lizenzgebühren für die Nutzung | Oft Lizenzkosten |
| **Beispiele** | TCP/IP, HTTP, DNS | Früher: Novell IPX/SPX, AppleTalk |

**Wichtige Unterscheidung:** Offener Standard ≠ Open Source. Ein offener Standard bedeutet, dass die **Spezifikation** frei zugänglich ist. Die Implementierung kann trotzdem proprietär sein — z.B. ist der Windows TCP/IP-Stack proprietärer Code, folgt aber dem offenen TCP/IP-Standard. Umgekehrt kann Open-Source-Software auf proprietären Standards basieren.

> **Quellen:** Zisler Kap. 1.2 (S. 23)

> **RZ-Relevanz:** Im RZ-Betrieb ist die Unterscheidung zwischen offenen und proprietären Standards eine tägliche Entscheidung. Offene Standards vermeiden Vendor Lock-in: Wer z.B. auf Kubernetes (offener Standard, CNCF) setzt, kann zwischen verschiedenen Anbietern wechseln (On-Prem, AWS EKS, Azure AKS). Proprietäre Lösungen (z.B. VMware NSX für Netzwerkvirtualisierung) bieten oft bessere Integration, binden aber an einen Hersteller. Bei der Containerplattform sind offene Standards wie OCI (Container-Images), CNI (Networking) und CSI (Storage) die Grundlage für Flexibilität und Herstellerunabhängigkeit.
