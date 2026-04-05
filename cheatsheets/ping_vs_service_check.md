# Ping vs. service check: why ping alone is not enough

## The problem

Ping uses ICMP (Internet layer). Many servers and firewalls block ICMP but still serve traffic on TCP ports like 443 (HTTPS).

Ping success proves one thing: IP routing works.
Ping failure proves nothing definitive. It could be a firewall rule, not a real outage.

## Real-world example: amazon.de

```bash
# Ping → 100% packet loss
ping -c 2 amazon.de
# PING amazon.de (54.239.33.91): 0 packets received, 100% packet loss

# curl → HTTP response comes back
curl -I --connect-timeout 3 https://amazon.de
# HTTP/1.1 301 Moved Permanently
# Server: Server
# Location: https://www.amazon.de/
```

Amazon blocks ICMP but serves HTTPS normally. The Internet layer (IP routing) works fine — only ICMP is filtered.

## Firewall vs. real outage

| Check | Command | Result |
|-------|---------|--------|
| DNS resolves? | `nslookup host` | IP shown → domain exists |
| Port reachable? | `curl -I --connect-timeout 3 https://host` | HTTP response → server lives, ICMP blocked |
| Both fail? | — | Real connectivity problem |

## Fake domain vs. firewall block

| | Fake domain | ICMP blocked (amazon.de) |
|---|---|---|
| `ping` | `Unknown host` | `100% packet loss` |
| DNS | No resolution | Returns IP |
| `curl` | Connection error | HTTP response |
| Cause | Domain does not exist | Firewall drops ICMP |

## RZ takeaway

Don't rely only on `ping` to check if a server is reachable. Always check the actual service port:

```bash
# Step 1: DNS check
nslookup <host>

# Step 2: Service check on the port you care about
curl -I --connect-timeout 3 https://<host>

# Alternative: raw TCP check
telnet <host> 443
```
