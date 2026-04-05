# Tag 6 Lab — Befehle erklärt

## ifconfig — Netzwerk-Interfaces anzeigen

Zeigt alle Netzwerk-Interfaces (physisch + virtuell) mit IP, MAC, Status.

```bash
ifconfig
```

Beispiel-Ausgabe (gekürzt):

```
en0: flags=8863<UP,BROADCAST,RUNNING,SIMPLEX>
        inet 192.168.1.48 netmask 0xffffff00 broadcast 192.168.1.255
        ether 8a:17:8d:01:de:0a
        status: active
```

| Feld | Bedeutung |
|------|-----------|
| `en0` | Interface-Name (hier: WLAN) |
| `UP, RUNNING` | Interface ist aktiv und verbunden |
| `inet 192.168.1.48` | IPv4-Adresse dieses Interfaces |
| `netmask 0xffffff00` | Subnetzmaske (= 255.255.255.0 = /24) |
| `broadcast 192.168.1.255` | Broadcast-Adresse des Netzes |
| `ether 8a:17:8d:01:de:0a` | MAC-Adresse der Netzwerkkarte |
| `status: active` | Physisch verbunden |

Nützliche Varianten:

```bash
ifconfig en0              # Nur ein bestimmtes Interface
ifconfig en0 | grep inet  # Nur die IP-Adresse
```

---

## networksetup -listallnetworkservices — Netzwerkdienste auflisten

Zeigt die macOS-Dienste (die Namen, die du in Systemeinstellungen → Netzwerk siehst).

```bash
networksetup -listallnetworkservices
```

Beispiel-Ausgabe:

```
Wi-Fi
Thunderbolt Bridge
iPhone USB
```

Unterschied zu `ifconfig`: `ifconfig` zeigt technische Interfaces (`en0`, `lo0`), `networksetup` zeigt die benutzerfreundlichen Dienstnamen (`Wi-Fi`).

---

## netstat -rn -f inet — Routing-Tabelle anzeigen

Zeigt wohin dein Mac Pakete schickt, je nach Zieladresse.

```bash
netstat -rn -f inet
```

| Flag | Bedeutung |
|------|-----------|
| `-r` | Routing-Tabelle anzeigen |
| `-n` | Numerisch (keine DNS-Auflösung, schneller) |
| `-f inet` | Nur IPv4 (ohne IPv6) |

Beispiel-Ausgabe (gekürzt):

```
Destination        Gateway            Netif
default            192.168.1.1        en0
127                127.0.0.1          lo0
192.168.1          link#14            en0
```

| Zeile | Bedeutung |
|-------|-----------|
| `default → 192.168.1.1 via en0` | Alles was nicht lokal ist → an den Router (Gateway) |
| `127 → lo0` | Localhost-Traffic bleibt lokal im Loopback |
| `192.168.1 → en0` | Geräte im Heimnetz sind direkt erreichbar, kein Gateway nötig |

---

## scutil --dns — DNS-Konfiguration anzeigen

Zeigt welche DNS-Server dein Mac befragt, um Domainnamen aufzulösen.

```bash
scutil --dns | grep "nameserver\["
```

Beispiel-Ausgabe:

```
  nameserver[0] : 192.168.1.1
```

Hier ist der Router (`192.168.1.1`) der DNS-Server. Er leitet DNS-Anfragen an den DNS des ISP oder öffentliche DNS-Server weiter.

---

## ping — Erreichbarkeit testen

Schickt ICMP Echo Requests an ein Ziel und misst die Antwortzeit.

```bash
ping -c 4 192.168.1.1
```

| Flag | Bedeutung |
|------|-----------|
| `-c 4` | Nur 4 Pakete senden (ohne `-c` läuft es endlos) |

Beispiel-Ausgabe:

```
64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=4.400 ms

--- 192.168.1.1 ping statistics ---
4 packets transmitted, 4 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 4.400/5.879/9.350/2.022 ms
```

| Feld | Bedeutung |
|------|-----------|
| `64 bytes` | Größe der Antwort |
| `icmp_seq=0` | Paketnummer (0, 1, 2, 3...) |
| `ttl=64` | Time to Live — wird pro Router-Hop um 1 reduziert. TTL 64 = Ziel ist direkt nebenan |
| `time=4.400 ms` | Roundtrip-Zeit (hin + zurück) |
| `0.0% packet loss` | Alle Pakete kamen an |

### Drei Ping-Tests: von nah nach fern

```bash
ping -c 4 192.168.1.1    # 1. Gateway (lokal, ~6ms)
ping -c 4 1.1.1.1        # 2. Cloudflare (Internet per IP, ~29ms)
ping -c 4 google.com     # 3. Google (Internet per Name, ~37ms)
```

| Test | Was wird geprüft |
|------|-----------------|
| Gateway | Funktioniert mein lokales Netz? (Schicht 1-3) |
| `1.1.1.1` | Komme ich ins Internet? (Gateway + Routing) |
| `google.com` | Funktioniert DNS + Internet? (DNS-Auflösung + Routing) |

Wenn Test 1 klappt aber 2 nicht → Problem beim Gateway/ISP.
Wenn Test 2 klappt aber 3 nicht → DNS ist kaputt.

---

## arp -a — ARP-Cache anzeigen

Zeigt die gelernten IP → MAC-Zuordnungen deines Macs.

```bash
arp -a
```

Beispiel-Ausgabe:

```
? (192.168.1.1) at e4:c0:e2:56:cc:b0 on en0 [ethernet]
? (192.168.1.17) at 26:ab:69:ee:44:28 on en0 [ethernet]
```

| Feld | Bedeutung |
|------|-----------|
| `192.168.1.1` | IP-Adresse des Geräts |
| `e4:c0:e2:56:cc:b0` | MAC-Adresse, die per ARP gelernt wurde |
| `on en0` | Über welches Interface erreichbar |

So weiß dein Mac, an welche Hardware-Adresse er Frames schicken muss, ohne jedes Mal per Broadcast fragen zu müssen.
