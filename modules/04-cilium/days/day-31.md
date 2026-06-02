# Tag 31 — Ch3: Cilium Basics

**Modul:** 04 — Cilium: Up and Running  
**Buch:** Ch3 — Getting Started with Cilium  
**Ziel:** Cilium in einem kind-Cluster installieren, erste Verbindungen beobachten, erste Network Policy anlegen

---

## Flashcard-Recap (gestern abgeschlossen)

Du hast bereits alle 5 Konzepte verinnerlicht:
- Cilium Agent (pro Node) vs. Operator (cluster-weit, einmalig)
- Hubble: eBPF → ring buffer → Hubble Server → Relay → UI/CLI
- Endpoint = konkretes Objekt mit IP | Identity = numerische ID aus Labels
- Policy-Enforcement via Identity (nicht IP) — stabil bei Pod-Neustart

---

## Lab-Aufgaben

### Aufgabe 1 — Cluster-Check

Du hast einen kind-Cluster mit Cilium. Bevor du anfängst: Welchen Befehl würdest du zuerst ausführen, um zu prüfen ob Cilium korrekt läuft?

*(Tipp: es gibt ein CLI-Tool das speziell dafür gemacht ist)*

---

### Aufgabe 2 — Endpoints inspizieren

Cilium verwaltet **Endpoints** — einen pro Pod (plus ein paar System-Endpoints).

Frage: Mit welchem Befehl listest du alle aktuellen Cilium-Endpoints auf?

Und was ist der Unterschied zwischen dem Status `ready` und `not-ready` bei einem Endpoint?

---

### Aufgabe 3 — Identity verstehen

Starte zwei Pods mit unterschiedlichen Labels:

```bash
kubectl run pod-a --image=nginx --labels="app=frontend"
kubectl run pod-b --image=nginx --labels="app=backend"
```

Frage: Haben pod-a und pod-b dieselbe Cilium-Identity? Wie kannst du das herausfinden?

---

### Aufgabe 4 — Erste Network Policy

Standardmäßig erlaubt Cilium allen Traffic (kein Default-Deny).

Erstelle eine **CiliumNetworkPolicy**, die folgendes tut:
- Ziel: `app=backend`
- Erlaubt eingehenden Traffic **nur** von Pods mit `app=frontend`
- Alles andere wird geblockt (Ingress Default-Deny)

Schreib das YAML — bevor du es anwendest, erklär kurz was `endpointSelector` und `fromEndpoints` bedeuten.

---

### Aufgabe 5 — Policy testen

Nach dem Anwenden der Policy:

1. Welchen Befehl nutzt du, um von pod-a auf pod-b zu testen?
2. Was erwartest du bei einem Pod mit `app=other`?
3. Wie siehst du in Hubble ob Traffic erlaubt oder geblockt wurde?

---

### Bonus — Hubble CLI

Falls Hubble aktiviert ist:

```bash
hubble observe --follow
```

Frage: Was zeigt `hubble observe` genau — rohe Pakete oder verarbeitete Flow-Events? Was ist der Unterschied?

---

## Ziel am Ende des Tages

- [ ] `cilium status` zeigt alles grün
- [ ] Endpoints und Identities können inspiziert werden
- [ ] Erste CiliumNetworkPolicy wurde angelegt und getestet
- [ ] Grundlegendes Verständnis von Hubble-Flows
