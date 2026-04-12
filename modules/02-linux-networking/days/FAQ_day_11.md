# FAQ — Tag 11: Linux Networking Erste Schritte

---

**Was sagt MTU aus? Und warum hat `lo` MTU 65536?**

MTU (Maximum Transmission Unit) definiert die maximale Paketgröße bevor ein Paket zerstückelt wird. Ethernet hat MTU 1500 wegen physikalischer Hardware-Limits. `lo` hat kein Kabel — das Paket bleibt im RAM des Systems — deshalb erlaubt Linux hier 65536 Bytes. Im RZ relevant: Cilium/VXLAN fügen Header hinzu, wenn MTU nicht angepasst wird, werden Pakete gedroppt.

---

**BROADCAST = alle, MULTICAST = Gruppe — oder umgekehrt?**

- BROADCAST = an **alle** im Subnetz (Zieladresse `ff:ff:ff:ff:ff:ff`)
- MULTICAST = an eine **bestimmte Gruppe** (nur Geräte die sich registriert haben)

Die Flags bei `ip link show` bedeuten nur: das Interface ist fähig solche Pakete zu empfangen/senden.

---

**Ist der ARP-Check ein bitweiser AND?**

Nein — beim ARP-Check macht jedes Gerät nur einen simplen Vergleich: "Steht in der ARP-Anfrage meine eigene IP?" Kein Rechnen, reiner Vergleich.

Der bitweise AND kommt beim Subnetting: `IP AND Subnetzmaske = Netzadresse` — damit prüft ein Gerät ob das Ziel im selben Subnetz liegt oder über den Gateway muss.

---

**Flutet nur der Switch Broadcasts, oder auch andere Geräte?**

| Gerät | Flutet? |
|---|---|
| Switch | Ja — innerhalb der Broadcast Domain |
| Hub | Ja — blind, an alle Ports |
| Router | Nein — stoppt Broadcasts hart |
| Access Point | Ja — im eigenen WLAN-Segment |

Broadcasts verlassen niemals den Router — sie bleiben immer lokal in der Broadcast Domain. Deshalb gibt es kein weltweites Broadcast.

---

**Wie zeige ich nur ein bestimmtes Interface an?**

In der VM (Linux):
```bash
ip addr show enp0s1
```

Auf dem Mac:
```bash
ifconfig en0
```

---

**Könnte der Nachbar dieselbe Gateway-IP haben wie ich?**

Ja. `192.168.x.x` ist ein privater IP-Bereich — jeder Router zuhause kann denselben Bereich nutzen. Diese IPs werden nie ins Internet geroutet, sie sind nur lokal gültig. Millionen Router weltweit könnten `192.168.100.1` haben — sie sehen sich nie.

---

**Was ist bridge100 und warum taucht es nicht in `ip link show` der VM auf?**

`bridge100` ist ein virtuelles Interface das Multipass auf dem Mac erstellt — ein Software-Switch. Es hat die IP `192.168.2.1` und ist der Gateway für alle Multipass-VMs.

Es taucht nicht in `ip link show` der VM auf weil es nicht auf der VM existiert — es ist auf dem Mac. `ip link show` zeigt nur Interfaces die auf diesem System selbst existieren.

---

**Was genau passiert bei NAT?**

NAT (in der Praxis meist PAT — Port Address Translation) führt eine Tabelle:

Ausgehend:
```
VM:    192.168.2.2:54321  →  8.8.8.8:443
Mac:   192.168.100.206:54321  →  8.8.8.8:443  (IP wird ersetzt)
```

Eingehend:
```
Antwort kommt auf Port 54321 → Mac schaut in NAT-Tabelle → leitet an 192.168.2.2 weiter
```

Der Port ist der Schlüssel — damit unterscheidet NAT welches Paket wohin gehört, auch wenn mehrere Geräte gleichzeitig kommunizieren.

---

**Warum sagt man NAT, meint aber PAT?**

Technisch korrekt wäre:
- NAT = nur IP wird übersetzt, 1:1 Mapping
- PAT = IP + Port wird übersetzt, viele IPs teilen eine öffentliche IP

Was Heimrouter und Macs machen ist PAT. Aber in der Praxis sagt jeder NAT — in Dokumentationen, Kubernetes, Cisco-Kursen. Das hat sich so eingebürgert. In der Netzwerktechnik werden viele Begriffe ungenau oder synonym verwendet (z.B. Router/Gateway, Subnetzmaske/Prefix-Length).

---

**Gibt es in Kubernetes denselben Traffic-Weg wie von der VM ins Internet?**

Ja, exakt denselben Weg — nur mit anderen Namen:

| Unser Setup | K8s Äquivalent |
|---|---|
| VM | Pod |
| bridge100 | Linux Bridge / veth pair auf dem Node |
| Mac (NAT) | Node (macht NAT für Pod-Traffic) |
| Heimrouter | Upstream-Router im RZ |

Der Pod hat eine IP aus dem PodCIDR (z.B. `10.244.x.x`) — außerhalb des Clusters unbekannt. Der Node tauscht die Pod-IP gegen seine Node-IP aus (NAT). Cilium ersetzt diesen Teil mit eBPF statt iptables — effizienter, besser debuggbar mit Hubble.

---

**Warum taucht das Gateway nicht in `ip link show` auf?**

`ip link show` zeigt nur Interfaces die auf **dieser Maschine** existieren. Das Gateway `192.168.2.1` ist auf dem Mac, nicht auf der VM — es ist ein fremdes Gerät im Netz.

`ip route show` hingegen zeigt wohin Pakete geschickt werden — auch zu fremden Geräten.

Analogie: `ip link show` = Liste deiner eigenen Türen. `ip route show` = Karte die auch zeigt wo die Nachbarn wohnen.

---

## Reflexionsfragen

**Was ist der Unterschied zwischen `ip addr` und `ifconfig`?**

Nicht nur Linux vs Mac — `ifconfig` gibt es auch auf Linux, ist aber veraltet (deprecated). Der echte Unterschied:
- `ifconfig` — kommt aus der BSD-Welt, älter, weniger Features, auf Linux nicht mehr weiterentwickelt
- `ip addr` — kommt aus dem `iproute2`-Paket, moderner Linux-Standard, mehr Details und Kontrolle

Auf Linux immer `ip` nutzen. `ifconfig` funktioniert noch, gehört aber nicht mehr zum Standard.

---

**Wozu braucht man das `lo`-Interface?**

Zwei Gründe:
1. Lokale Prozesskommunikation — Prozesse auf demselben Host können sich über `127.0.0.1` ansprechen ohne das echte Netzwerk zu nutzen
2. Isolation — Services die sich bewusst nur an `127.0.0.1` binden (z.B. eine lokale Datenbank) sind von außen nicht erreichbar. `lo` ist immer verfügbar, auch wenn kein Netzwerk vorhanden ist.

---

**Was würde passieren wenn kein Default Gateway gesetzt wäre?**

Nur Pakete deren Ziel nicht in einem direkt bekannten Subnetz liegt, haben keinen Weg und werden verworfen. Lokale Kommunikation im selben Subnetz (`192.168.2.x`) würde weiterhin funktionieren — dafür ist kein Gateway nötig. Das System wäre also nur noch lokal erreichbar, kein Internet, keine fremden Netze.
