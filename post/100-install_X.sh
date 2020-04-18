#!/usr/bin/env bash
set -e

# Installing packages
yay -Syu --needed --noconfirm xorg-server xf86-video-intel xorg-xinit \
	gnu-free-fonts xorg-xrandr


echo "----------------------------------------------------------------------"
echo "     Fix for Intel backlight control"
echo "----------------------------------------------------------------------"
if [ -f /sys/class/backlight/intel_backlight/actual_brightness ] ; then
	sudo cp misc/10-backlight.conf /etc/X11/xorg.conf.d/10-backlight.conf
fi
