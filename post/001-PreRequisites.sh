#!/usr/bin/env bash
set -e

ThisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! hash yay 2>/dev/null; then
  echo "----------------------------------------------------------------------"
  echo "     Installing dependencies"
  echo "----------------------------------------------------------------------"
  sudo pacman -S --needed --noconfirm go
  echo "----------------------------------------------------------------------"
  echo "     Installing yay"
  echo "----------------------------------------------------------------------"
fi

if ! hash yay 2>/dev/null # If yay doesn't exist
then
  echo "----------------------------------------------------------------------"
  echo "     Installing yay"
  echo "----------------------------------------------------------------------"
  if [ -d $ThisDir/yay ]; then rm -rfv $ThisDir/yay; fi
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --needed --noconfirm
  if [ -d $ThisDir/yay ]; then rm -rfv $ThisDir/yay; fi
  yay -Rsn go --noconfirm
fi


if ! hash yadm; then
  echo "----------------------------------------------------------------------"
  echo "     Installing git and yadm"
  echo "----------------------------------------------------------------------"
  yay -S --needed --noconfirm git yadm-git
fi