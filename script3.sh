#!/bin/bash
set -uo pipefail
command -v iptables >/dev/null || { echo 'Falta iptables.' >&2; exit 1; }
[[ $EUID -eq 0 ]] || { echo 'Usa privilegios de administración dentro del laboratorio.' >&2; exit 1; }
# ============================================================
# Práctica 10 - Script 3: Menú de gestión del Firewall
# Seguridad Perimetral - Ingeniería en Telemática
# ============================================================

# Rutas a los scripts (ajusta si están en otra ubicación)
SCRIPT1="$(dirname "$0")/script1.sh"
SCRIPT2="$(dirname "$0")/script2.sh"

# ----------------------------------------------------------
# Función: mostrar encabezado / logo del equipo
# ----------------------------------------------------------
mostrar_menu() {
    clear
    echo "##############################################################"
    echo "##                                                          ##"
    echo "##        🔥  FIREWALL MANAGER - IPTABLES v1.0  🔥         ##"
    echo "##          Seguridad Perimetral - Ingeniería en            ##"
    echo "##                      Telemática                         ##"
    echo "##                                                          ##"
    echo "##############################################################"
    echo ""
    echo "  Selecciona una opción:"
    echo ""
    echo "  1) Listar interfaces de red"
    echo "  2) Ejecutar Script 1  (Firewall básico)"
    echo "  3) Ejecutar Script 2  (Firewall avanzado)"
    echo "  4) Listar reglas en ejecución"
    echo "  5) Botón de pánico    (Limpiar reglas y abrir todo)"
    echo "  6) Salir"
    echo ""
    echo "##############################################################"
    echo -n "  Opción: "
}

# ----------------------------------------------------------
# Función: listar interfaces de red
# ----------------------------------------------------------
listar_interfaces() {
    echo ""
    echo "==============================="
    echo "  Interfaces de red disponibles"
    echo "==============================="
    if command -v ip &>/dev/null; then
        ip address
    else
        ifconfig
    fi
    echo ""
}

# ----------------------------------------------------------
# Función: ejecutar script 1
# ----------------------------------------------------------
ejecutar_script1() {
    echo ""
    if [[ ! -f "$SCRIPT1" ]]; then
        echo "[ERROR] No se encontró el archivo: $SCRIPT1"
    else
        bash "$SCRIPT1"
    fi
    echo ""
}

# ----------------------------------------------------------
# Función: ejecutar script 2
# ----------------------------------------------------------
ejecutar_script2() {
    echo ""
    if [[ ! -f "$SCRIPT2" ]]; then
        echo "[ERROR] No se encontró el archivo: $SCRIPT2"
    else
        bash "$SCRIPT2"
    fi
    echo ""
}

# ----------------------------------------------------------
# Función: listar reglas actuales de iptables
# ----------------------------------------------------------
listar_reglas() {
    echo ""
    echo "==============================="
    echo "  Reglas actuales de iptables"
    echo "==============================="
    iptables -L -v --line-numbers
    echo ""
}

# ----------------------------------------------------------
# Función: botón de pánico - limpiar todo y aceptar todo
# ----------------------------------------------------------
boton_panico() {
    local confirmacion
    read -r -p 'Esta opción abre todo el tráfico IPv4 filtrado. Escribe ABRIR para confirmar: ' confirmacion || return
    [[ "$confirmacion" == 'ABRIR' ]] || { echo 'Cancelado.'; return; }
    echo ""
    echo "⚠️  BOTÓN DE PÁNICO ACTIVADO ⚠️"
    echo "[*] Limpiando todas las reglas..."
    iptables -F || return
    iptables -X || return
    iptables -Z || return
    echo "[*] Estableciendo políticas en ACCEPT..."
    iptables -P INPUT ACCEPT || return
    iptables -P OUTPUT ACCEPT || return
    iptables -P FORWARD ACCEPT || return
    echo "[✔] Firewall limpio. Todo el tráfico está permitido."
    echo ""
}

# ----------------------------------------------------------
# Bucle principal del menú
# ----------------------------------------------------------
while true; do
    mostrar_menu
    read -r opcion || exit 0

    case $opcion in
        1)
            listar_interfaces
            read -rp "Presiona ENTER para continuar..."
            ;;
        2)
            ejecutar_script1
            read -rp "Presiona ENTER para continuar..."
            ;;
        3)
            ejecutar_script2
            read -rp "Presiona ENTER para continuar..."
            ;;
        4)
            listar_reglas
            read -rp "Presiona ENTER para continuar..."
            ;;
        5)
            boton_panico
            read -rp "Presiona ENTER para continuar..."
            ;;
        6)
            clear
            echo "Saliendo del sistema de gestión de firewall. ¡Hasta luego!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo "[!] Opción inválida. Intenta de nuevo."
            sleep 1
            ;;
    esac
done
