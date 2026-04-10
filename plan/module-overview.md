# Modulübersicht — 100-Days Networking Challenge

> **Ausrichtung:** RZ-Stack der RISE Infrastruktur (RKE2, Cilium, MetalLB, HAProxy, Istio)
> Modul 01 abgeschlossen. Ab Tag 11: hands-on first, kein Tag ohne Terminal.

---

## Modul 01: Grundlagen (Tag 1-10) ✓

**Zisler:** Kap. 1 (S. 17-31) — Definition Netzwerke, TCP/IP, OSI, Netzwerktypen, RFCs
**Dordal:** Kap. 1 — Schichten, Datenrate, Pakete, Topologie, Routing-Schleifen, Überlast
**Lab:** Netzwerk-Interfaces erkunden (`ifconfig`, `networksetup`), dig, traceroute, curl

---

## Modul 02: Linux Networking (Tag 11-20)

**Warum:** Jeder Pod, jeder Service, jedes Cilium-Feature baut auf Linux-Netzwerk-Primitives auf.

**Quellen:**
- **LARTC** (Linux Advanced Routing & Traffic Control) — Hauptquelle für ip, Routing, Namespaces
- **Dordal Kap. 6** — Verbindungen, Interfaces, Encoding
- **Peterson & Davie Kap. 1** — Systems-Perspektive (optionale Vertiefung)
- **Tanenbaum Kap. 1.4–1.5** — Protokollschichten (optionale Vertiefung)

**Themen:**
- `ip addr`, `ip link`, `ip route`, `ip neigh`
- Network Namespaces (`ip netns`) — das Fundament von Container-Networking
- veth pairs — wie Container mit dem Host kommunizieren
- Linux Bridges — wie Switches in Software
- `ethtool`, `ss`, `tcpdump`

**RZ-Relevanz:** RKE2 läuft auf Ubuntu — diese Commands sind tägliches Handwerkszeug auf jedem Node.
**Tools:** Multipass (Ubuntu VMs), Wireshark
**Lab-Highlight:** Manuell ein Container-Netzwerk nachbauen (ohne Docker) — veth pair + netns + bridge

---

## Modul 03: Ethernet, IP & Subnetting (Tag 21-30)

**Warum:** IP-Adressierung ist täglich in K8s — PodCIDR, ServiceCIDR, Node IPs, MetalLB IP-Pools.

**Themen:**
- Ethernet-Frames, ARP, MAC-Adressen
- IPv4-Subnetting (CIDR, Subnetzmasken, Berechnung)
- IPv6-Grundlagen (RKE2 unterstützt dual-stack)
- Routing-Tabellen lesen und verstehen
- NAT / Masquerading (relevant für K8s NodePort)

**RZ-Relevanz:** Subnetting für PodCIDR/ServiceCIDR planen, MetalLB IP-Pools dimensionieren.
**Tools:** Packet Tracer (Topologien), Multipass (echte Subnetze)
**Lab-Highlight:** Zwei Multipass-VMs in verschiedenen Subnetzen — Routing manuell konfigurieren

---

## Modul 04: Routing & BGP (Tag 31-40)

**Warum:** Cilium BGP Control Plane + MetalLB BGP-Mode — ohne BGP-Grundverständnis kein Debugging.

**Themen:**
- Static Routing vs Dynamic Routing
- OSPF-Grundlagen (Konzept)
- BGP deep dive — eBGP vs iBGP, AS-Nummern, Route Advertisement, Path Selection
- FRRouting (FRR) — das BGP-Tool das Cilium intern nutzt
- Traceroute-Analyse, Routing-Loops

**RZ-Relevanz:** Cilium BGP Control Plane + MetalLB BGP-Mode direkt im Stack.
**Tools:** Packet Tracer (BGP-Simulation), FRRouting in Multipass
**Lab-Highlight:** BGP-Session zwischen zwei FRR-Instanzen aufbauen, Route ankündigen

---

## Modul 05: TCP/UDP & DNS/CoreDNS (Tag 41-50)

**Warum:** TCP-Timeouts, DNS-Resolution-Fehler, CoreDNS-Config — tägliches RZ-Debugging.

**Themen:**
- TCP-Handshake, States, Timeouts, Congestion Control, Retransmissions
- UDP-Charakteristiken (DNS, QUIC)
- DNS-Auflösung deep dive (Rekursion, Caching, TTL, NXDOMAIN)
- CoreDNS — Konfiguration, Plugins (forward, cache, rewrite), Debugging
- `dig`, DNS-Debugging-Workflow in K8s

**RZ-Relevanz:** CoreDNS ist der DNS in jedem RKE2-Cluster — bei DNS-Problemen ist das der erste Anlaufpunkt.
**Tools:** Wireshark (TCP/DNS-Traces), CoreDNS lokal in Docker
**Lab-Highlight:** CoreDNS lokal konfigurieren + DNS-Anfragen mit Wireshark tracen

---

## Modul 06: Load Balancing — HAProxy & MetalLB (Tag 51-60)

**Warum:** HAProxy und MetalLB sind direkt im RZ-Stack. Verstehen wie sie funktionieren ist Pflicht.

**Themen:**
- L4 vs L7 Load Balancing — Unterschied und Einsatz
- HAProxy-Konfiguration (Frontend, Backend, ACLs, Health Checks)
- MetalLB — L2-Mode vs BGP-Mode, IP-Pool-Konfiguration, ARP-Announcement
- Session Persistence, Connection Draining
- Troubleshooting: warum bekommt ein Service keine externe IP?

**RZ-Relevanz:** Direkt aus dem Stack — HAProxy + MetalLB sind produktiv im Einsatz.
**Tools:** HAProxy in Multipass/Docker, MetalLB in Kind-Cluster
**Lab-Highlight:** HAProxy vor zwei Backends + MetalLB BGP-Mode in Kind

---

## Modul 07: K8s Networking Basics (Tag 61-70)

**Warum:** Direkte Grundlage für alles im RZ-Alltag.

**Themen:**
- CNI-Konzept — wie Pods IPs bekommen, IPAM
- Pod-to-Pod Networking (gleicher Node / verschiedene Nodes)
- Services: ClusterIP, NodePort, LoadBalancer, ExternalName
- Ingress + IngressController
- kube-proxy vs eBPF (Cilium ersetzt kube-proxy)
- DNS in K8s: Service Discovery, headless Services, ExternalDNS

**RZ-Relevanz:** Das ist der Alltag — Services debuggen, Ingress konfigurieren, DNS-Probleme lösen.
**Tools:** Kind-Cluster, kubectl, Wireshark
**Lab-Highlight:** Traffic-Path eines Requests von außen bis zum Pod vollständig nachverfolgen

---

## Modul 08: Cilium & eBPF (Tag 71-80)

**Warum:** Cilium ist der CNI im RZ. Ohne Cilium-Kenntnisse debuggt man im Dunkeln.

**Themen:**
- eBPF-Grundlagen — was ist es, warum schneller als iptables
- Cilium-Architektur (cilium-agent, Hubble, cilium-operator)
- NetworkPolicies mit Cilium (L3/L4/L7)
- Hubble — Netzwerk-Observability, Flow-Logs
- Cilium-Debugging-Workflow (`cilium status`, `cilium endpoint list`, Hubble UI)
- Cilium BGP Control Plane konfigurieren

**RZ-Relevanz:** Cilium ist der CNI. NetworkPolicy-Debugging, eBPF-Verständnis, Hubble für Observability.
**Tools:** Kind + Cilium, Hubble CLI, cilium CLI
**Lab-Highlight:** NetworkPolicy debuggen mit Hubble + BGP in Cilium konfigurieren

---

## Modul 09: Service Mesh — Istio (Tag 81-90)

**Warum:** Viele Tenants im RZ nutzen Istio. Traffic-Management und mTLS sind Alltag.

**Themen:**
- Service Mesh Konzept — warum? (mTLS, Observability, Traffic Management)
- Istio-Architektur (istiod, Envoy Sidecar, Control Plane vs Data Plane)
- VirtualService, DestinationRule, Gateway
- mTLS — wie funktioniert es, wie debugge ich es
- Istio + Cilium — Zusammenspiel (CNI chaining)
- OPA Gatekeeper — Policy-Enforcement auf K8s-Ebene

**RZ-Relevanz:** Viele Tenants nutzen Istio. OPA Gatekeeper ist direkt im Stack.
**Tools:** Kind + Istio, istioctl, kiali
**Lab-Highlight:** mTLS zwischen zwei Services erzwingen + Traffic-Splitting 90/10

---

## Modul 10: Observability & End-to-End (Tag 91-100)

**Warum:** Im RZ muss man Probleme finden können — von der Metrik bis zur Root Cause.

**Themen:**
- Prometheus-Metriken für Netzwerk (kube-state-metrics, node-exporter, cilium-metrics)
- VictoriaMetrics als Prometheus-Alternative (Migration im RZ)
- Netzwerk-Metriken: Packet Loss, Latenz, Bandbreite, Verbindungsanzahl
- End-to-End Troubleshooting-Workflow
- Abschluss-Lab: Reales Netzwerkproblem in Kind-Cluster — vollständige Diagnose

**RZ-Relevanz:** kube-prometheus-stack → VictoriaMetrics ist aktive Migration im Stack.
**Tools:** VictoriaMetrics in Kind, Grafana, Hubble
**Lab-Highlight:** Intentional network issue — vollständige Diagnose von Metrik bis Root Cause

---

## Was gestrichen wurde (vs. ursprünglicher Plan)

| Gestrichen | Warum |
|------------|-------|
| Kabeltypen (Koax, Cat6, LWL) | Nicht relevant für RZ-Alltag |
| WLAN (802.11, Frequenzbänder) | Kein WLAN im Datacenter |
| PoE, Steckerbelegungen | Nicht relevant |
| SMB, NFS, FTP | Nicht im RZ-Stack |
| SMTP, SCP-Details | Nicht im RZ-Stack |

## Definition of Done (Tag 100)

- Netzwerkproblem in Kind-Cluster von Symptom bis Root Cause debuggen
- Cilium NetworkPolicies schreiben und mit Hubble verifizieren
- MetalLB BGP-Mode konfigurieren
- HAProxy als L4/L7 LB konfigurieren
- CoreDNS-Probleme in K8s diagnostizieren
- Traffic-Path von außen bis zum Pod erklären
- Istio mTLS konfigurieren und debuggen
