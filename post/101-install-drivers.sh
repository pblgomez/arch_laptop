#!/usr/bin/env bash
set -e

if lspci -k | grep -q -A 2 -E "(VGA|3D)" | grep NVIDIA; then
  yay -Syu --needed --noconfirm bumblebee nvidia bbswitch
  sudo usermod -a -G bumblebee $USER
fi
