#!/bin/bash
set -euo pipefail
command -v iptables >/dev/null || { echo 'Falta iptables.' >&2; exit 1; }
[[ $EUID -eq 0 ]] || { echo 'Usa privilegios de administración dentro del laboratorio.' >&2; exit 1; }
# ============================================================
# Práctica 10 - Script 1: Firewall iptables perimetral LAN
# Seguridad Perimetral - Ingeniería en Telemática
# ============================================================

# IPs de los equipos de trabajo (modificar según corresponda)
EQUIPOS_TRABAJO="192.168.1.0/24"

echo "[*] Aplicando Script 1 - Reglas básicas de firewall..."

# ----------------------------------------------------------
# 1. Limpiar reglas existentes
# ----------------------------------------------------------
iptables -F
iptables -X
iptables -Z

# ----------------------------------------------------------
# 2. Establecer políticas por defecto en DROP
# ----------------------------------------------------------
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Tráfico local y resolución de nombres para la navegación de este host.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
for dns in 8.8.8.8 8.8.4.4; do
    iptables -A OUTPUT -p udp --dport 53 -d "$dns" -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 53 -d "$dns" -j ACCEPT
done

# ----------------------------------------------------------
# 3. Aceptar conexiones ya establecidas y relacionadas
# ----------------------------------------------------------
iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# ----------------------------------------------------------
# 4. Habilitar puertos para navegación web estándar (80) y encriptada (443)
# ----------------------------------------------------------
iptables -A OUTPUT -p tcp --dport 80  -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT  -p tcp --sport 80  -m state --state ESTABLISHED     -j ACCEPT

iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT  -p tcp --sport 443 -m state --state ESTABLISHED     -j ACCEPT

# ----------------------------------------------------------
# 5. Limitar conexión SSH solo para equipos de trabajo
# ----------------------------------------------------------
iptables -A INPUT  -p tcp --dport 22 -s "$EQUIPOS_TRABAJO" -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d "$EQUIPOS_TRABAJO" -m state --state ESTABLISHED     -j ACCEPT

# ----------------------------------------------------------
# 6. Limitar el ping a 3 paquetes por segundo (con burst de 5)
# ----------------------------------------------------------
iptables -A INPUT  -p icmp --icmp-type echo-request \
         -m limit --limit 3/second --limit-burst 5 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# ----------------------------------------------------------
echo "[✔] Script 1 aplicado correctamente."
