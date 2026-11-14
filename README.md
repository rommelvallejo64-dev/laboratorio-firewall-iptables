# Laboratorio de firewall con iptables

Práctica académica de filtrado IPv4 en un host Linux. Contiene reglas básicas, reglas avanzadas y un menú de administración. Aunque la cabecera original menciona un firewall perimetral, estos scripts bloquean FORWARD y no implementan un router, NAT ni filtrado IPv6.

## Archivos

- `script1.sh`: políticas y reglas básicas.
- `script2.sh`: reglas avanzadas y destinos permitidos.
- `script3.sh`: menú para consultar interfaces, aplicar scripts y mostrar reglas.

## Entorno de prueba

Usar una máquina virtual Linux desechable, con iptables instalado y acceso a su consola. Los scripts requieren privilegios de administración, limpian reglas existentes y cambian políticas de tráfico. Pueden interrumpir conexiones; no aplicarlos sobre la laptop, un servidor de trabajo o una sesión remota sin recuperación.

Antes de ejecutar, revisar todos los comandos y ajustar la topología. `192.168.1.0/24` representa una LAN de laboratorio; `192.0.2.10` es un destino de ejemplo y debe reemplazarse por una máquina del laboratorio. La dirección específica presente en el archivo original fue sustituida.

Primero revisar sintaxis con `for archivo in script1.sh script2.sh script3.sh; do bash -n "$archivo" || break; done`. Guardar las reglas previas mediante `sudo iptables-save > reglas-previas.v4`; recuperarlas desde consola con `sudo iptables-restore < reglas-previas.v4`. No subir ese respaldo al repositorio.

El menú se inicia con `sudo bash script3.sh`. La opción de limpieza/apertura del tráfico es una operación de recuperación de laboratorio, no un endurecimiento de seguridad.

## Validación pendiente

Se agregó comprobación de privilegios y disponibilidad de iptables, interrupción ante errores en los perfiles, loopback y DNS al perfil básico. Se eliminó el ACCEPT genérico de SYN del perfil avanzado porque permitía abrir otros puertos; no se presenta como protección contra SYN flood. Se corrigió el destino del ping saliente al segmento de trabajo y se agregó confirmación escrita para la opción que abre el tráfico. Se conservaron las cabeceras originales; las mejoras de revisión se prepararon con asistencia de Codex.

El estado ESTABLISHED/RELATED permite continuar conexiones ya existentes. Aplicar un perfil no revoca automáticamente conexiones previas ni reemplaza otras tablas o reglas IPv6. Las reglas se aplican en secuencia, no de manera atómica, y un fallo puede dejar un perfil parcial: usar una VM desechable y consola con recuperación.

Se incluye un flujo de GitHub Actions para sintaxis Bash y ShellCheck sin aplicar reglas. La revisión de sintaxis Bash y ShellCheck pasó en GitHub Actions. La comprobación local de Bash no pudo arrancar por restricciones de permisos de Windows.

Documentar versiones de Linux e iptables, diagrama de interfaces, conectividad inicial, resultado de cada regla y recuperación. Las pruebas deben distinguir tráfico permitido y bloqueado, y verificar la dirección y cadena correspondientes. No se ejecutaron las reglas durante esta preparación.

## Créditos

Se conservaron las cabeceras de la práctica. La autoría individual o de equipo debe confirmarse antes de agregar una licencia o atribuir el diseño a una sola persona.
