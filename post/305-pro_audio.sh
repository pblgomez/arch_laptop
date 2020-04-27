#!/usr/bin/env bash
set -e

if pacman -Q jack2 >/dev/null; then
  echo "----------------------------------------------------------------------"
  echo "     Configuring jack"
  echo "----------------------------------------------------------------------"
  file=/etc/security/limits.conf
  grep '@audio.*rtprio' $file || echo "@audio   -   rtprio    95" | sudo tee -a $file
  grep '@audio.*memlo' $file || echo "@audio   -   memlock    unlimited" | sudo tee -a $file
fi
