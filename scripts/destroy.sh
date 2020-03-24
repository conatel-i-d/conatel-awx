#!/bin/bash
#
# Title:      AWX Conatel
# Author(s):  Guzmán Monné
# URL:        https://github.com/conatel-i-d/awx-conatel
# GNU:        MIT
###############################################################################
menuprime(){  
  clear
  # Menu interface
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨🚨🚨 AWX Conatel: Atención! Esta acción no tiene retorno 🚨🚨🚨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚦 ¿Esta seguro que desea continuar?:

EOF
  tee <<-EOF
[Y] Si
[N] No

[M] Volver al menu

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  # Standby
  read -p '▶️  Eliga una opción | Presione [ENTER]: ' typed < /dev/tty

  case $typed in
    Y )
      make destroy
      exit ;;
    N )
      exit ;;
    M )
      exit ;;
    * )
      menuprime ;;
  esac
}

menuprime