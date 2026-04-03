# Tag 5 — Netzwerktypen (PAN, LAN, MAN, WAN)

## Leseauftrag

- **Zisler** Kap. 1.4 (S. 28-29): Räumliche Abgrenzung von Netzwerken
- **Dordal** Kap. 1.5 (optional): Topologie

## Kernkonzepte

- [x] Klassifikation nach geografischer Ausdehnung
- [x] PAN: Personal Area Network (Bluetooth, ein Raum)
- [x] LAN: Local Area Network (Gebäude, Etage)
- [x] MAN: Metropolitan Area Network (Campus, Stadtgebiet)
- [x] WAN: Wide Area Network (überregional, weltweit)
- [x] Intranet: privates, nicht-öffentliches Netzwerk
- [x] Topologie: Stern, Ring, Bus, Mesh — Auswirkungen auf Redundanz

## Flashcards

**Q:** Was ist ein LAN?
**A:** Local Area Network — ein Netzwerk innerhalb eines Gebäudes oder einer Etage. Typisch: Ethernet, hohe Bandbreite, geringe Latenz.

**Q:** Was unterscheidet MAN von WAN?
**A:** MAN = Metropolitan Area Network (Campus/Stadt, z.B. Uni-Netz). WAN = Wide Area Network (überregional/weltweit, z.B. das Internet).

**Q:** Was ist ein Intranet?
**A:** Ein privates, nicht-öffentliches Datennetzwerk, z.B. das interne Firmennetz — nutzt TCP/IP, ist aber nicht aus dem Internet erreichbar.

**Q:** Was bedeutet Mesh-Topologie?
**A:** Jeder Knoten ist mit mehreren anderen verbunden. Vorteil: hohe Redundanz und Ausfallsicherheit. Nachteil: komplex und teuer.

## Mini-Quiz

1. Du vernetzt mehrere Gebäude auf einem Werksgelände — welcher Netzwerktyp ist das?

   **MAN (Metropolitan Area Network)** — aus den vier Standardkategorien (PAN, LAN, MAN, WAN) passt MAN am besten, da ein Werksgelände über ein einzelnes Gebäude hinausgeht aber nicht überregional ist. Präziser wäre **CAN (Campus Area Network)**, das zwischen LAN und MAN liegt und genau dieses Szenario beschreibt — mehrere Gebäude auf einem zusammenhängenden Gelände. CAN wird in Zisler/Dordal nicht explizit behandelt, ist aber in der Praxis ein gängiger Begriff.

   > **Quellen:** Zisler Kap. 1.4 (S. 28–29)

   > **RZ-Relevanz:** Ein Rechenzentrum ist typischerweise ein LAN, aber sobald mehrere RZ-Gebäude auf einem Campus verbunden werden (z.B. Primary-RZ + Backup-RZ auf demselben Gelände), entsteht ein CAN/MAN. Die Verbindung zwischen den Gebäuden erfolgt meist über Dark Fiber (eigene Glasfaser) mit hoher Bandbreite und niedriger Latenz. Das ist entscheidend für synchrone Storage-Replikation zwischen RZ-Standorten — bei zu hoher Latenz (>5ms) funktioniert synchrone Replikation nicht mehr zuverlässig, und man muss auf asynchrone Replikation umstellen, was RPO (Recovery Point Objective) verschlechtert.

---

2. Warum bietet eine Mesh-Topologie mehr Ausfallsicherheit als eine Stern-Topologie?

   In einer **Stern-Topologie** gibt es nur **einen Pfad** zwischen zwei Knoten — fällt eine Verbindung oder der zentrale Switch aus, ist die Kommunikation unterbrochen (Single Point of Failure). In einer **Mesh-Topologie** existieren **mehrere redundante Pfade** zwischen den Knoten. Fällt ein Pfad aus, wird automatisch auf eine Alternativroute umgeschaltet. Protokolle wie **STP (Spanning Tree Protocol)** verhindern dabei Schleifen im Normalbetrieb und aktivieren Ersatzpfade bei Ausfall.

   > **Quellen:** Dordal Kap. 1.5 (S. 38–39); Zisler Kap. 4.6.2 (S. 214)

   > **RZ-Relevanz:** Kein produktives RZ arbeitet mit reiner Stern-Topologie — die Ausfallsicherheit wäre zu gering. Standard ist eine **Leaf-Spine-Architektur** (eine Form von Partial Mesh): Jeder Leaf-Switch (Top-of-Rack) ist mit **jedem** Spine-Switch verbunden. Fällt ein Spine aus, läuft der Traffic über die verbleibenden Spines weiter. ECMP (Equal-Cost Multi-Path) verteilt den Traffic gleichmäßig über alle verfügbaren Pfade — kein STP-Blocking nötig. In Kubernetes-Umgebungen kommt darüber hinaus Software-defined Networking (Cilium/Calico) hinzu, das auf Layer 3/4 zusätzliche Redundanz durch mehrere Routen zwischen Nodes bietet.

---

3. Was ist der Unterschied zwischen Internet und Intranet?

   **Internet** = weltweites, öffentliches Netzwerk aus verbundenen Servern und Rechnern, für jeden zugänglich. **Intranet** = internes, abgeschottetes Netzwerk einer Firma oder Organisation, nicht aus dem Internet erreichbar. Beide nutzen dieselbe Technologie (TCP/IP) — der Unterschied ist rein organisatorisch (öffentlich vs. privat), nicht technisch.

   > **Quellen:** Zisler Kap. 1.4 (S. 28–29)

   > **RZ-Relevanz:** Im RZ ist die Trennung zwischen Internet und Intranet eine der grundlegenden Sicherheitsarchitekturen. Typisches Muster: **DMZ (Demilitarisierte Zone)** als Pufferzone zwischen Internet und Intranet. Webserver und Reverse Proxies stehen in der DMZ und sind aus dem Internet erreichbar, die eigentlichen Applikationsserver und Datenbanken stehen im Intranet dahinter. Firewalls kontrollieren den Traffic in beide Richtungen. In modernen RZ-Setups mit Kubernetes wird das über **Network Policies** und **Ingress Controller** abgebildet: der Ingress Controller ist das Tor zum Internet, Network Policies isolieren interne Services voneinander (Micro-Segmentation).
