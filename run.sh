#!/bin/bash
#
# Title:      AWX Conatel
# Author(s):  Guzmán Monné
# URL:        https://github.com/conatel-i-d/awx-conatel
# GNU:        MIT
###############################################################################

initprime(){
  clear
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❗️ Verificando el estado del proyecto
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Espere por favor...
EOF
  make init > /dev/null
  menuprime
}

exitprime(){
  clear
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👋 Muchas gracias por utilizar nuestro producto
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  bash ./scripts/signature.sh
}

continueprime() {
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Ok!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  # Standby
  read -p '▶️  Presione [ENTER] para continuar: '
  menuprime
}

menuprime(){
  clear
  # Menu interface
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌎 AWX Conatel: ¿Que quieres hacer?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌵 Seleccione alguna de las siguientes opciones:

EOF
  tee <<-EOF
[1] Editar archivo de inventario
[2] Editar archivo de variables
[3] Levantar el servidor de AWX
[4] Respaldar el servidor de AWX
[5] Visualizar la lista de reespaldos existentes
[6] Restaurar una versión anterior del servidor

[P] Probar conectividad con el servidor
[Q] Salir

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  # Standby
  read -p '▶️  Eliga una opción | Presione [ENTER]: ' typed < /dev/tty

  case $typed in
    1 )
      bash ./scripts/edit-file.sh ./hosts.yml
      continueprime ;;
    2 )
      bash ./scripts/edit-file.sh ./vars.yml
      continueprime ;;
    3 )
      make up
      continueprime ;;
    4 )
      make backup
      continueprime ;;
    5 )
      make list-backups
      continueprime ;;
    6 )
      make restore
      continueprime ;;
    P )
      make ping
      continueprime ;;
    Q )
      exitprime
      exit ;;
    * )
      menuprime ;;
  esac
}

# Start script
initprime