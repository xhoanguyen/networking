# Tag 1 — Was ist ein Netzwerk?

## Leseauftrag

- **Zisler** Kap. 1.1 (S. 19-22): Definition und Eigenschaften von Netzwerken
- **Dordal** Kap. 1.1-1.3 (optional): Schichten, Datenrate, Pakete

## Kernkonzepte

- [x] Paketorientierung vs. leitungsvermittelte Kommunikation (Telefonie)
- [x] Heterogene Netze: unterschiedliche Geräte/OS kommunizieren gleichberechtigt
- [x] Netzwerkprotokoll: Regelwerk für Adressierung, Flusssteuerung, Fehlererkennung
- [x] Historische Motivation: Ausfallsicherheit (Baran) vs. Effizienz/Multiplexing (Davies)

## Flashcards

**Q:** Was bedeutet "paketorientiert"?
**A:** Daten werden in kleine Einheiten (Pakete) aufgeteilt, die eigenständig ihren Weg zum Ziel finden — im Gegensatz zur leitungsvermittelten Kommunikation (z.B. klassische Telefonie), wo ein fester Kanal reserviert wird.

**Q:** Was ist ein heterogenes Netz?
**A:** Ein Netzwerk, in dem Teilnehmer mit verschiedenen Hardware-Architekturen und Betriebssystemen gleichberechtigt miteinander kommunizieren können.

**Q:** Was sind die drei Hauptaufgaben eines Netzwerkprotokolls?
**A:** 1) Adressierung, 2) Verbindungs- und Flusssteuerung, 3) Fehlererkennung.

**Q:** Was ist der Unterschied zwischen Datenrate, Durchsatz und Goodput?
**A:** 
- Datenrate = reine Bit-Übertragungsrate. 
- Durchsatz = effektive Rate inkl. Overhead. 
- Goodput = nutzbare Daten auf Anwendungsebene (ohne Retransmissions).

## Mini-Quiz

### 1. Warum ist Paketvermittlung ausfallsicherer als Leitungsvermittlung?

**Antwort:** Bei Paketvermittlung werden Daten in einzelne Pakete aufgeteilt, die **unabhängig voneinander** über verschiedene Wege zum Ziel geroutet werden. Fällt eine Leitung oder ein Knoten aus, können die Pakete über alternative Pfade umgeleitet werden. Einzelne verlorene Pakete können erneut angefordert werden.

Bei Leitungsvermittlung wird dagegen ein **fester, exklusiver Kanal** zwischen Sender und Empfänger reserviert (wie beim klassischen Telefonnetz). Fällt ein Abschnitt dieses Kanals aus, bricht die gesamte Verbindung zusammen — es gibt keinen alternativen Weg.

Zusätzlich blockiert Leitungsvermittlung die Leitung **exklusiv**, auch wenn gerade keine Daten fließen. Paketvermittlung teilt die Kapazität effizienter auf, weil sich mehrere Verbindungen die Leitungen teilen (Multiplexing).

> **Quellen:** Zisler Kap. 1.1 (S. 19-20), Dordal Kap. 1.2

> **RZ-Relevanz:** In einer Containerplattform (Kubernetes) ist Paketvermittlung die Grundlage. Pods kommunizieren über ein Overlay-Netzwerk, in dem Pakete dynamisch geroutet werden. Fällt ein Node aus, werden Pods auf andere Nodes rescheduled und die Netzwerkpfade passen sich automatisch an — genau das Prinzip der Ausfallsicherheit durch Paketvermittlung.

---

### 2. Nenne ein Beispiel für ein heterogenes Netz in deinem Alltag.

**Antwort:** Ein Heim-WLAN, in dem ein Computer (macOS), ein Drucker (eigene Firmware), ein Smartphone (Android/iOS) und ein Smart-TV (Linux-basiert) miteinander kommunizieren. Alle nutzen unterschiedliche Hardware und Betriebssysteme, können aber über gemeinsame Netzwerkprotokolle (TCP/IP) problemlos Daten austauschen.

> **Quellen:** Zisler Kap. 1.1 (S. 21)

> **RZ-Relevanz:** Ein Rechenzentrum ist per Definition ein heterogenes Netz — Linux-Server, Windows-Hosts, Storage-Appliances, Netzwerk-Switches und Container mit verschiedenen Base-Images kommunizieren alle über standardisierte Protokolle. Gerade in einer Containerplattform laufen Workloads mit unterschiedlichsten OS-Images (Alpine, Ubuntu, Distroless) auf gemeinsamer Infrastruktur.

---

### 3. Paul Baran und Donald Davies hatten unterschiedliche Motivationen für die Paketvermittlung — welche?

**Antwort:**

- **Paul Baran** (RAND Corporation, USA, 1960er): Militärischer Hintergrund. Sein Ziel war ein Kommunikationsnetz, das auch bei **Teilzerstörung** (z.B. durch einen Atomschlag) weiter funktioniert. Er entwarf ein verteiltes Netzwerk ohne zentrale Knoten — fällt ein Teil aus, finden die Nachrichten alternative Wege. → **Ausfallsicherheit**

- **Donald Davies** (NPL, Großbritannien, 1965): Sein Ziel war die **effizientere Nutzung** von Leitungen. Durch Aufteilung in kleine Pakete und Multiplexing können sich viele Verbindungen eine Leitung teilen, statt sie exklusiv zu blockieren. Er prägte auch den Begriff "Packet Switching". → **Effizienz durch Multiplexing**

Beide kamen unabhängig voneinander zur gleichen Lösung — Paketvermittlung — aber aus völlig unterschiedlichen Motivationen.

> **Quellen:** Zisler Kap. 1.1 (S. 19-20), Dordal Kap. 1.1

> **RZ-Relevanz:** Beide Motivationen sind im RZ-Betrieb direkt relevant: Ausfallsicherheit (Redundanz, HA-Cluster) und Effizienz (Bandbreite teilen statt reservieren). In Kubernetes sorgen z.B. Service-Meshes wie Istio für beides: Traffic wird dynamisch umgeleitet bei Ausfällen und Load-Balancing verteilt die Last effizient.
