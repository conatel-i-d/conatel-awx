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
  make init
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
[1] Editar archivo de inventario                    [hosts.yml]
[2] Editar archivo de variables                     [vars.yml]
[3] Editar archivo de variables de entorno          [.env]
[4] Levantar el servidor de AWX                     [ansible-playbook up.yml]
[5] Respaldar el servidor de AWX                    [ansible-playbook backup.yml]
[6] Visualizar la lista de reespaldos existentes    [ansible-playbook list-backups.yml]
[7] Restaurar una versión anterior del servidor     [ansible-playbook restore.yml]

[I] Instalar roles desde ansible-galaxy             [make install-roles]
[L] Listar los roles instalados                     [make list-roles]
[P] Probar conectividad con el servidor             [ansible-playbook ping.yml]
[X] Eliminar implementación actual                  [ansible-playbook destroy.yml]
[Q] Salir

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  # Standby
  read -p '▶️  Eliga una opción | Presione [ENTER]: ' typed < /dev/tty

  case $typed in
    1 )
      bash ./scripts/edit-file.sh ./hosts.yml
      menuprime ;;
    2 )
      bash ./scripts/edit-file.sh ./vars.yml
      menuprime ;;
    3 )
      bash ./scripts/edit-file.sh ./.env
      menuprime ;;
    4 )
      make up
      continueprime ;;
    5 )
      make backup
      continueprime ;;
    6 )
      make list-backups
      continueprime ;;
    7 )
      make restore
      continueprime ;;
    I )
      make install-roles
      continueprime ;;
    L )
      make list-roles
      continueprime ;;
    P )
      make ping
      continueprime ;;
    X )
      bash ./scripts/destroy.sh
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
