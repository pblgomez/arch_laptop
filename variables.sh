#!/usr/bin/env bash
set -e

### Variables
# lsblk -o +LABEL,PARTLABEL,UUID,PARTUUID                                   # To check what device to install to

DRIVE=/dev/sda
distro="arch"
set_hostname="archlinux"

name_system="cryptsystem"                                                   # nombre de la particion root cifrada
encryption=""                                                               # you can leave this blank
# encryption="--type luks1 --align-payload=8192 -s 256 -c aes-xts-plain64"  # you can leave this blank
root_vol_name="system"                                                      # nombre de la particion root descifrada"

swap=n                                                                      # yes(y) or no(n)
swap_size="8"                                                               # Swap size in GB
name_swap="cryptswap"                                                       # nombre de la particion de swap cifrada

kernel="linux"                                                              # linux, linux-zen, linux-lts

TZ="Atlantic/Canary"
locale="en_US"

bootloader="grub"                                                           # grub,refind
plymouth="no"
### End of Variables
