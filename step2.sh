#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/variables.sh

echo "############################################################"
echo "# Password for root:"
echo "############################################################"
passwd

echo "############################################################"
echo "# Time"
echo "############################################################"
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc

echo "############################################################"
echo "# Locales"
echo "############################################################"
sed -i "/#${locale}.UTF-8/s/^#//g" /etc/locale.gen
echo "LANG=${locale}.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
locale-gen

echo "############################################################"
echo "# Hostname and hosts and network"
echo "############################################################"
echo "$set_hostname" > /etc/hostname
echo "127.0.1.1     $set_hostname.localdomain   $set_hostname" >> /etc/hosts
systemctl enable dhcpcd

echo "############################################################"
echo "# mkinitcpio"
echo "############################################################"
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p $kernel

echo "############################################################"
echo "# rEFInd"
echo "############################################################"
refind-install
cd /boot/EFI
mkdir boot
cp refind/refind_x64.efi boot/bootx64.efi
uuid_crypto=$(lsblk -fs | grep crypt | awk '{print $4}')
root_part_name=$(df | grep '/$' | awk '{print $1}' | sed 's/.*\///' )
cp /boot/EFI/refind/refind.conf /boot/EFI/refind/refind.conf.orig
echo '
menuentry "Arch Linux" {
    icon     /EFI/refind/icons/os_arch.png
    volume   "ESP"
    loader   /vmlinuz-'$kernel'
    initrd   /intel-ucode.img
    initrd   /initramfs-'$kernel'.img
    options  "cryptdevice=UUID='$uuid_crypto':'$root_part_name' root=/dev/mapper/'$root_part_name' rootflags=subvol=root rw add_efi_memmap"
    submenuentry "Boot to terminal" {
        add_options "systemd.unit=multi-user.target"
    }
    enabled
}
' >> /boot/EFI/refind/refind.conf
sed -i 's/^#scanfor.*/scanfor manual,internal,external,optical/' /boot/EFI/refind/refind.conf
sed -i 's/^timeout.*/timeout 3/' /boot/EFI/refind/refind.conf

echo "############################################################"
echo "# crypttab"
echo "############################################################"
echo "$root_part_name    UUID=$uuid_crypto    none                    luks,timeout=180" >> /etc/crypttab

rm -rfv $DIR/step2.sh $DIR/variables.sh
echo "############################################################"
echo "# Finished. Now type:"
echo "# exit"
echo "# shutdown now"
echo "############################################################"
exit