#!/usr/bin/env bash
set -e

lsblk -o +LABEL,PARTLABEL,UUID,PARTUUID
DRIVE=/dev/sda
sgdisk --zap-all $DRIVE
sgdisk --clear \
         --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=2:0:+8GiB   --typecode=2:8200 --change-name=2:cryptswap \
         --new=3:0:0       --typecode=3:8300 --change-name=3:cryptsystem \
           $DRIVE
sleep 5


echo "FORMAT EFI PARTITION"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

echo "Encrypt System Partition"
cryptsetup luksFormat --type luks1 --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/cryptsystem
cryptsetup open /dev/disk/by-partlabel/cryptsystem system

echo "Bring Up Encrypted Swap"
cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap
mkswap -L swap /dev/mapper/swap
swapon -L swap

echo "Create and mount BTRFS subvolumes"
mkfs.btrfs --force --label system /dev/mapper/system
o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime
mount -t btrfs LABEL=system /mnt

btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/snapshots
umount -R /mnt
mount -t btrfs -o subvol=root,$o_btrfs LABEL=system /mnt
mount -t btrfs -o subvol=home,$o_btrfs LABEL=system /mnt/home
mount -t btrfs -o subvol=snapshots,$o_btrfs LABEL=system /mnt/.snapshots

echo "Mount EFI partition"
mkdir /mnt/efi
mount LABEL=EFI /mnt/efi

echo "Install base package group"
pacstrap /mnt base git

echo "fstab Generation and Modification"
genfstab -L -p /mnt >> /mnt/etc/fstab
sed -i s+LABEL=swap+/dev/mapper/swap+ /mnt/etc/fstab

echo "cryptswap        /dev/disk/by-partlabel/cryptswap        /dev/urandom        swap,offset=2048,cipher=aes-xts-plain64,size=256" >> /mnt/etc/crypttab

# Ponemos aquí la uuid de l aparticion la usaremos después
lsblk -fs | grep btrfs | awk '{print $1}' > /mnt/root/nombre_particion
lsblk -fs | grep crypto | awk '{print $4}' > /mnt/root/uuid_de_crypto
#lsblk -fs | grep system | awk '{ print $4 }' > /mnt/root/uuid_de_system 

echo "Boot into new system"
for i in {0..9}
do
  echo 'pts/'$i >> /mnt/etc/securetty
done
cp -Rvu /root/arch_laptop /mnt/root/.
systemd-nspawn -bD /mnt
