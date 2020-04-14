#!/usr/bin/env bash
set -e

##
## SCRIPT DE INSTALACION DE ARCHLINUX CON LUKS+BTRFS
##

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/variables.sh

echo "############################################################"
echo "# Clearing disk and make partitions"
echo "############################################################"
sgdisk --zap-all $DRIVE
if [ $swap = y ]; then
    sgdisk --clear \
         --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=2:0:+${swap_size}GiB   --typecode=2:8200 --change-name=2:$name_swap \
         --new=3:0:0       --typecode=3:8300 --change-name=3:$name_system \
           $DRIVE
else
    sgdisk --clear \
         --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=3:0:0       --typecode=3:8300 --change-name=3:$name_system= \
           $DRIVE
fi

echo "############################################################"
echo "# Initate pacman keyring and selecting mirrors"
echo "############################################################"
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
pacman -Sy --noconfirm --needed reflector
reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist

if [ $swap = y ]; then
    echo "############################################################"
    echo "# Bring Up Encrypted Swap"
    echo "############################################################"
    swapoff -a
    cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/$name_swap swap
    mkswap -L swap /dev/mapper/swap
    swapon -L swap
fi

echo "############################################################"
echo "# Setting time"
echo "############################################################"
timedatectl set-ntp true

echo "############################################################"
echo "# Encrypting system partitions"
echo "############################################################"
eval cryptsetup luksFormat ${encryption} /dev/disk/by-partlabel/$name_system
cryptsetup open /dev/disk/by-partlabel/$name_system $root_vol_name

echo "############################################################"
echo "# Formatting partitions"
echo "############################################################"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mkfs.btrfs --force --label archroot /dev/mapper/$root_vol_name

echo "############################################################"
echo "# Mounting partitions"
echo "############################################################"
mount /dev/mapper/$root_vol_name /mnt

echo "############################################################"
echo "# Creating subvolumes"
echo "############################################################"
btrfs subvolume create /mnt/@${distro}
btrfs subvolume create /mnt/@${distro}_home
umount /mnt

echo "############################################################"
echo "# Mounting the subvolumes + boot"
echo "############################################################"
o_btrfs=defaults,x-mount.mkdir,compress=lzo,ssd,noatime
mount -o subvol=@${distro},$o_btrfs /dev/mapper/$root_vol_name /mnt/
mkdir /mnt/boot
mount -o subvol=@${distro}_home,$o_btrfs /dev/mapper/$root_vol_name /mnt/home
mount /dev/disk/by-partlabel/EFI /mnt/boot

echo "############################################################"
echo "# Installing base system"
echo "############################################################"
pacstrap /mnt base btrfs-progs base-devel intel-ucode $kernel \
    efibootmgr grub \
    dhcpcd wpa_supplicant netctl networkmanager

echo "############################################################"
echo "# Generating fstab and chroot to new arch system"
echo "############################################################"
genfstab -L /mnt >> /mnt/etc/fstab
if [ $swap = y ]; then
    sed -i s+LABEL=swap+/dev/mapper/swap+ /mnt/etc/fstab
    echo "swap      /dev/disk/by-partlabel/${name_swap}        /dev/urandom    swap,offset=2048,cipher=aes-xts-plain64,size=256" >> /mnt/etc/crypttab
fi


echo "############################################################"
echo "# Finished step1, now to step2"
echo "############################################################"
cp $DIR/step2.sh /mnt/root/.
cp $DIR/variables.sh /mnt/root/.
arch-chroot /mnt

echo "############################################################"
echo "# Finished step2, now shutdown"
echo "############################################################"
sleep 10
shutdown now
