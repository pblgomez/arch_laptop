#!/usr/bin/env bash
set -e

### Variables
# lsblk -o +LABEL,PARTLABEL,UUID,PARTUUID   # To check what device
DRIVE=/dev/sda
root_vol_name=system
swap=y # yes(y) or no(n)
kernel="linux-zen"
encryption="--type luks1 --align-payload=8192 -s 256 -c aes-xts-plain64" # you can leave this blank
### End of Variables