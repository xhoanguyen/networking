# Modulübersicht — 100-Days Networking Challenge

## Modul 01: Grundlagen (Tag 1-10)

**Zisler:** Kap. 1 (S. 17-31) — Definition Netzwerke, TCP/IP, OSI, Netzwerktypen, RFCs
**Dordal:** Kap. 1 — Schichten, Datenrate, Pakete, Topologie, Routing-Schleifen, Überlast
**Lab:** Netzwerk-Interfaces erkunden (`ifconfig`, `networksetup`)

## Modul 02: Netzwerktechnik (Tag 11-20)

**Zisler:** Kap. 2 (S. 32-105) — Koaxial, Twisted-Pair, LWL, WLAN, PoE, Steckerbelegungen
**Dordal:** Kap. 4 (Wireless LANs, Wi-Fi), Kap. 6 (Verbindungen, Kodierung, Framing)
**Lab:** WLAN-Analyse, Kabeltypen-Übersicht

## Modul 03: Ethernet & Switching (Tag 21-30)

**Zisler:** Kap. 2.6 (CSMA/CD, CSMA/CA), Kap. 4.5-4.6 (Bridges, Hubs, Switches, VLANs)
**Dordal:** Kap. 2 (Ethernet-Grundlagen, Lernalgorithmus), Kap. 3 (STP, VLAN, SDN, OpenFlow)
**Lab:** Ethernet-Frames mit Wireshark capturen

## Modul 04: IP-Adressierung & Subnetting (Tag 31-40)

**Zisler:** Kap. 3 (S. 106-153) — MAC, ARP, IPv4/IPv6-Adressen, Subnetzmasken, Berechnungen
**Dordal:** Kap. 9 (IPv4, Fragmentierung, NAT, Subnetze), Kap. 11-12 (IPv6, Tunneling)
**Lab:** Subnetting-Rechner in Python bauen

## Modul 05: Adressen-Praxis (Tag 41-50)

**Zisler:** Kap. 4.1-4.4 (S. 154-200) — MAC setzen, DHCP, DNS-Konfiguration, Namensauflösung
**Dordal:** Kap. 10 (DNS, ARP, DHCP, ICMP, Traceroute)
**Lab:** DNS-Abfragen mit `dig`, lokalen DNS (dnsmasq) aufsetzen

## Modul 06: Routing (Tag 51-60)

**Zisler:** Kap. 4.7 (Routing, PAT, Gateway), Kap. 5 (ICMP/ICMPv6)
**Dordal:** Kap. 13 (Distanzvektor, Link-State), Kap. 14 (CIDR, hierarchisch), Kap. 15 (BGP)
**Lab:** Traceroute-Analyse, Routing-Tabelle lesen (`netstat -rn`)

## Modul 07: TCP, UDP, Ports, Firewalls (Tag 61-70)

**Zisler:** Kap. 6 (S. 254-291) — TCP/UDP-Header, Verbindungsauf-/-abbau, Ports, Firewalls, Proxy
**Dordal:** Kap. 16 (UDP, TFTP, RPC), Kap. 17-18 (TCP-Grundlagen, Probleme), Kap. 19 (Reno, Congestion)
**Lab:** TCP-Handshake in Wireshark, Portscan mit `nmap`

## Modul 08: Anwendungsprotokolle (Tag 71-78)

**Zisler:** Kap. 7 (S. 292-341) — SMB, NFS, HTTP, SMTP, SSH, TLS
**Zisler:** Kap. 8 (S. 342-378) — FTP, SCP, SSH-Tunnel
**Dordal:** Kap. 28 (RSA, TLS, SSH, IPsec, DNSSEC)
**Lab:** SSH-Tunnel aufbauen, TLS mit `openssl s_client` inspizieren

## Modul 09: Netzwerkpraxis & Sicherheit (Tag 79-88)

**Zisler:** Kap. 9 (S. 379-478) — Netzwerkplanung, VPN, Firewall, Wireshark, nmap, tcpdump
**Dordal:** Kap. 25 (SNMP, Netzwerkverwaltung), Kap. 27 (Hashing, Verschlüsselung)
**Lab:** Netzwerk-Audit des eigenen Heimnetzes

## Modul 10: K8s-Networking (Tag 89-100)

**Quellen:** Kubernetes-Dokumentation, Cilium/Calico Docs
**Themen:** CNI-Plugins, Pod-Networking, Services (ClusterIP, NodePort, LoadBalancer), Ingress, CoreDNS, Network Policies
**Lab:** Kind-Cluster mit Cilium aufsetzen, Service-Networking testen
