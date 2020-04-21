#!/usr/bin/env bash
set -e

# pulseaudio, pamixer

echo "----------------------------------------------------------------------"
echo "     Configuring pulseaudio"
echo "----------------------------------------------------------------------"
sudo sed -i 's/^autospawn = no/; autospawn = no/' /etc/pulse/client.conf
sudo sed -i 's/; autospawn = yes/autospawn = yes/' /etc/pulse/client.conf
