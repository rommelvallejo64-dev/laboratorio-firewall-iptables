#!/bin/bash
set -euo pipefail
command -v iptables >/dev/null || { echo 'Falta iptables.' >&2; exit 1; }
[[ $EUID -eq 0 ]] || { echo 'Usa privilegios de administración dentro del laboratorio.' >&2; exit 1; }
# ============================================================
# Práctica 10 - Script 2: Firewall iptables avanzado
# Seguridad Perimetral - Ingeniería en Telemática
# ============================================================

# IPs de los equipos de trabajo (modificar según corresponda)
EQUIPOS_TRABAJO="192.168.1.0/24"

# IP del servidor web autorizado
SERVIDOR_WEB="192.0.2.10"

# DNS permitidos (Google, como ejemplo)
DNS1="8.8.8.8"
DNS2="8.8.4.4"

echo "[*] Aplicando Script 2 - Reglas avanzadas de firewall..."

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

# ----------------------------------------------------------
# 3. Aceptar conexiones por Loopback
# ----------------------------------------------------------
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ----------------------------------------------------------
# 4. Aceptar conexiones ya establecidas y relacionadas
# ----------------------------------------------------------
iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# ----------------------------------------------------------
# 5. Habilitar conexiones hacia los DNS (UDP y TCP puerto 53)
# ----------------------------------------------------------
iptables -A OUTPUT -p udp --dport 53 -d "$DNS1" -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -d "$DNS2" -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -d "$DNS1" -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -d "$DNS2" -j ACCEPT

# ----------------------------------------------------------
# 6. Limitar conexión SSH solo para equipos de trabajo
# ----------------------------------------------------------
iptables -A INPUT  -p tcp --dport 22 -s "$EQUIPOS_TRABAJO" -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d "$EQUIPOS_TRABAJO" -m state --state ESTABLISHED     -j ACCEPT

# ----------------------------------------------------------
# 7. Aceptar tráfico web (HTTP:80 y HTTPS:443) solo hacia 192.0.2.10
# ----------------------------------------------------------
iptables -A OUTPUT -p tcp --dport 80  -d "$SERVIDOR_WEB" -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -d "$SERVIDOR_WEB" -m state --state NEW,ESTABLISHED -j ACCEPT

# ----------------------------------------------------------
# 8. Filtrar ping: solo lo pueden hacer quienes tienen permiso SSH
# ----------------------------------------------------------
iptables -A INPUT  -p icmp --icmp-type echo-request -s "$EQUIPOS_TRABAJO" -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply   -d "$EQUIPOS_TRABAJO" -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -d "$EQUIPOS_TRABAJO" -j ACCEPT

# ----------------------------------------------------------
# 9. Las conexiones nuevas restantes quedan bloqueadas por INPUT DROP.
# No aceptar SYN genéricos: el ACCEPT del original abría otros puertos.
# ----------------------------------------------------------

# ----------------------------------------------------------
echo "[✔] Script 2 aplicado correctamente."
