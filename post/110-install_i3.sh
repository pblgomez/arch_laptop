#!/usr/bin/env bash
set -e

echo "----------------------------------------------------------------------"
echo "     Installing i3"
echo "----------------------------------------------------------------------"
yay -S --needed --noconfirm i3-gaps dmenu i3status i3lock picom


# sudo sed -i 's/^#IdleAction=.*/IdleAction=suspend/' /etc/systemd/logind.conf
# sudo sed -i 's/^#IdleActionSec=.*/IdleActionSec=10min/' /etc/systemd/logind.conf
