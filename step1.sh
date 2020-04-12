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
         --new=2:0:+8GiB   --typecode=2:8200 --change-name=2:cryptswap \
         --new=3:0:0       --typecode=3:8300 --change-name=3:cryptsystem \
           $DRIVE
else
    sgdisk --clear \
         --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=3:0:0       --typecode=3:8300 --change-name=3:cryptsystem \
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
    cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap
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
#cryptsetup luksFormat /dev/disk/by-partlabel/cryptsystem
cryptsetup luksFormat $encryption /dev/disk/by-partlabel/cryptsystem
cryptsetup open /dev/disk/by-partlabel/cryptsystem $root_vol_name

echo "############################################################"
echo "# Formatting partitions"
echo "############################################################"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
# parted set 1 boot on
# parted set 1 esp on
mkfs.btrfs --force --label archroot /dev/mapper/$root_vol_name

echo "############################################################"
echo "# Mounting partitions"
echo "############################################################"
mkdir /mnt/subvolumes
mount /dev/mapper/$root_vol_name /mnt/subvolumes

echo "############################################################"
echo "# Creating subvolumes"
echo "############################################################"
btrfs subvolume create /mnt/subvolumes/home
btrfs subvolume create /mnt/subvolumes/root

echo "############################################################"
echo "# Mounting the subvolumes + boot"
echo "############################################################"
o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime
mount -o subvol=root,$o_btrfs /dev/mapper/$root_vol_name /mnt/arch-root
mkdir /mnt/arch-root/boot
mount -o subvol=home,$o_btrfs /dev/mapper/$root_vol_name /mnt/arch-root/home
mount /dev/disk/by-partlabel/EFI /mnt/arch-root/boot

echo "############################################################"
echo "# Installing base system"
echo "############################################################"
pacstrap /mnt/arch-root base btrfs-progs base-devel refind-efi intel-ucode $kernel \
    dhcpcd wpa_supplicant wireless_tools iw

echo "############################################################"
echo "# Generating fstab and chroot to new arch system"
echo "############################################################"
genfstab -L /mnt/arch-root >> /mnt/arch-root/etc/fstab
if [ $swap = y ]; then
    sed -i s+LABEL=swap+/dev/mapper/swap+ /mnt/arch-root/etc/fstab
    echo "swap      /dev/disk/by-partlabel/cryptswap        /dev/urandom    swap,offset=2048,cipher=aes-xts-plain64,size=256" >> /mnt/arch-root/etc/crypttab
fi


echo "############################################################"
echo "# Finished step1, now to step2"
echo "############################################################"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cp $DIR/step2.sh /mnt/arch-root/root/.
cp $DIR/variables.sh /mnt/arch-root/root/.
arch-chroot /mnt/arch-root

echo "############################################################"
echo "# Finished step2, now shutdown"
echo "############################################################"
sleep 10
shutdown now
