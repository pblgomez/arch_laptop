#!/usr/bin/env bash
set -e

# Installing packages
yay -Syu --needed --noconfirm xorg-server xf86-video-intel xorg-xinit \
	gnu-free-fonts xorg-xrandr
