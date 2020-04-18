#!/usr/bin/env bash
set -e

echo "----------------------------------------------------------------------"
echo "First edit apps.txt file and select what applications you want"
echo "Don't continue if you haven't done it. Crtl+c to cancel"
echo "----------------------------------------------------------------------"
sleep 5s

echo "----------------------------------------------------------------------"
echo "     Installing apps..."
echo "----------------------------------------------------------------------"
yay -Syyuu --needed --noconfirm `sed -e '/^#/d' apps.txt`



if [ -f /usr/bin/variety ]; then
	sed -i 's/icon = Light/icon = None/g' ~/.config/variety/variety.conf
fi