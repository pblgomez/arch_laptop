#!/usr/bin/env bash
set -e


ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for script in $ThisDir/???-*.sh
do
  echo $script
  printf "Executing script: %s\n" "$script"
  /$script
done
