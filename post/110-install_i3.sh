#!/usr/bin/env bash
set -e

echo "----------------------------------------------------------------------"
echo "     Installing i3"
echo "----------------------------------------------------------------------"
yay -S --needed --noconfirm i3-gaps dmenu i3status i3lock picom termite
