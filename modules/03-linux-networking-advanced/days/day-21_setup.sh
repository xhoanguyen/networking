#!/usr/bin/env bash
# Day 21 — Systematisches Netzwerk-Debugging
# Kaputtes Setup zum selbst debuggen.
# Verwendung: sudo bash day-21_setup.sh

set -e

# ── Cleanup ────────────────────────────────────────────────────────────────
echo "[*] Cleanup..."
ip netns del ns-web 2>/dev/null || true
ip netns del ns-db  2>/dev/null || true
ip link del br0     2>/dev/null || true
ip link del veth-web 2>/dev/null || true
ip link del veth-db  2>/dev/null || true

# ── Bridge ─────────────────────────────────────────────────────────────────
echo "[*] Bridge aufbauen..."
ip link add name br0 type bridge
ip addr add 10.0.0.1/24 dev br0
ip link set br0 up

# ── Namespaces ─────────────────────────────────────────────────────────────
echo "[*] Namespaces erstellen..."
ip netns add ns-web
ip netns add ns-db

# ── veth pairs ─────────────────────────────────────────────────────────────
echo "[*] veth pairs erstellen..."
ip link add veth-web type veth peer name br-web
ip link add veth-db  type veth peer name br-db

# Bridge-Seiten enslaven und hochbringen
ip link set br-web master br0 && ip link set br-web up
ip link set br-db  master br0 && ip link set br-db  up

# Namespace-Seiten verschieben
ip link set veth-web netns ns-web
ip link set veth-db  netns ns-db

# ── ns-web: Fehler 1 ───────────────────────────────────────────────────────
# IP gesetzt, aber Interface nicht hochgebracht
ip netns exec ns-web ip addr add 10.0.0.2/24 dev veth-web
ip netns exec ns-web ip link set lo up

# ── ns-db: Fehler 2 ────────────────────────────────────────────────────────
# Interface up, IP gesetzt, aber keine Default Route
ip netns exec ns-db ip link set veth-db up
ip netns exec ns-db ip addr add 10.0.0.3/24 dev veth-db
ip netns exec ns-db ip link set lo up

# ── Host: Fehler 3 ─────────────────────────────────────────────────────────
# IP Forwarding deaktiviert
sysctl -w net.ipv4.ip_forward=0 > /dev/null

echo ""
echo "Setup bereit. Viel Erfolg beim Debuggen!"
echo ""
echo "Ziel: ping von ns-web nach 8.8.8.8 zum Laufen bringen."
echo "Es gibt 3 Fehler — finde sie systematisch, Layer für Layer."
