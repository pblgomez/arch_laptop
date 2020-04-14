#!/usr/bin/env bash
set -e

### Variables
# lsblk -o +LABEL,PARTLABEL,UUID,PARTUUID   # To check what device
DRIVE=/dev/sda
distro="arch"
root_vol_name="system"                      # nombre de la particion root descifrada"
swap=y                                      # yes(y) or no(n)
name_swap="cryptswap"                       # nombre de la particion de swap cifrada
name_system="cryptsystem"                  # nombre de la particion root cifrada
kernel="linux-zen"
encryption="--type luks1 --align-payload=8192 -s 256 -c aes-xts-plain64" # you can leave this blank
locale="en_US"
set_hostname="archlinux"
bootloader="grub"                           # grub,refind
### End of Variables