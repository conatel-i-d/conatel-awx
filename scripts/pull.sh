#!/bin/bash
#
# Title:      AWX Conatel
# Author(s):  Guzmán Monné
# URL:        https://github.com/conatel-i-d/awx-conatel
# GNU:        MIT
###############################################################################
image_id=`docker images conateldigitalhub/conatel-awx:latest -q`
if [ "$image_id" == '' ]; then
  docker pull conateldigitalhub/conatel-awx:latest
else
  echo $image_id
fi