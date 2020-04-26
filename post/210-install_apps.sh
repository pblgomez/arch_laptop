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

if [ -f /usr/bin/tlp ]; then
  sudo systemctl enable tlp.service
fi

if [ -f /usr/bin/tlp ]; then
  sudo systemctl enable autorandr
fi

if [ -f /usr/bin/laptop_mode ]; then
  sudo systemctl enable laptop-mode.service
  echo "#!/usr/bin/env bash

light -T 0.4" | sudo tee /etc/laptop-mode/batt-start/brightness.sh
  sudo chmod +x /etc/laptop-mode/batt-start/brightness.sh
  echo "#!/usr/bin/env bash

light -S 100" | sudo tee /etc/laptop-mode/batt-stop/brightness.sh
  sudo chmod +x /etc/laptop-mode/batt-stop/brightness.sh
fi
