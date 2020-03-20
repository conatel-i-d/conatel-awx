#!/bin/bash
#
# Title:      AWX Conatel
# Author(s):  Guzmán Monné
# URL:        https://github.com/conatel-i-d/awx-conatel
# GNU:        MIT
###############################################################################
  clear
  # Menu interface
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏓 AWX Conatel: ¿Con que editor quieres editar el archivo "$1"?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌵 Seleccione alguna de las siguientes opciones:

EOF
  tee <<-EOF
[1] Vim
[2] Nano
[3] Visual Studio Code

[M] Volver al menu

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  # Standby
  read -p '▶️  Eliga una opción | Presione [ENTER]: ' typed < /dev/tty

  case $typed in
    1 )
      vim $1
      exit ;;
    2 )
      nano $1
      exit ;;
    3 )
      code $1
      exit ;;
    M )
      exit ;;
    * )
      menuprime ;;
  esac
}

menuprime