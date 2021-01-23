#!/usr/bin/env sh
#
#    _ \  |      |  
#   |   | __ \   |  Pablo Gómez
#   ___/  |   |  |  http://www.gitlab.com/pblgomez
#  _|    _.__/  _|
#
# Description: Execute all the *.sh files in this dir

set -e

ThisDir=$(dirname "$(readlink -f -- "$0")")
echo $ThisDir

for script in "$ThisDir"/???-*.sh
do
  echo "$script"
  printf "Executing script: %s\n" "$script"
  /"$script"
done
