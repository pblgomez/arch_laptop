#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/variables.sh

# echo "############################################################"
# echo "# Password for root:"
# echo "############################################################"
# passwd

echo "############################################################"
echo "# Create user"
echo "############################################################"
read -p "Enter username: " username
useradd -G sys,network,scanner,power,rfkill,users,video,uucp,storage,optical,lp,audio,wheel -s $(which zsh) -m $username
echo "Enter password:"
passwd $username
# Give sudoers permission
sed -i 's/# %w.*) ALL$/%wheel ALL=(ALL) ALL/g' /etc/sudoers
# Disable root permission
sed -i '/^root.*/ s/:x:/: :/' /etc/passwd

echo "############################################################"
echo "# Time"
echo "############################################################"
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc --utc

echo "############################################################"
echo "# Locales"
echo "############################################################"
sed -i "/#${locale}.UTF-8/s/^#//g" /etc/locale.gen
echo "LANG=${locale}.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" >> /etc/locale.conf
echo "LC_CTYPE=${locale}.UTF-8" >> /etc/locale.conf
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
echo "# Bootloader"
echo "############################################################"
# uuid_crypto=$(lsblk -fs | grep crypt | awk '{print $4}')
# root_part_name=$(df | grep '/$' | awk '{print $1}' | sed 's/.*\///' )
if [ $bootloader = "grub" ]; then
    echo "############################################################"
    echo "# GRUB"
    echo "############################################################"
    sed -i '/^#GRUB_ENABLE_CRYPTO.*/s/^#//' /etc/default/grub
    sed -i 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=3/' /etc/default/grub
    sed -i 's+GRUB_CMDLINE_LINUX=.*+GRUB_CMDLINE_LINUX="cryptdevice=/dev/disk/by-partlabel/'$name_system':'${root_vol_name}' root=/dev/mapper/'$root_vol_name'"+' /etc/default/grub
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
    grub-mkconfig --output /boot/grub/grub.cfg
elif [ $bootloader = "refind" ]; then
    echo "############################################################"
    echo "# rEFInd"
    echo "############################################################"
    refind-install
    cd /boot/EFI
    mkdir boot
    cp refind/refind_x64.efi boot/bootx64.efi
    cp /boot/EFI/refind/refind.conf /boot/EFI/refind/refind.conf.orig
    echo '
    menuentry "Arch Linux" {
        icon     /EFI/refind/icons/os_arch.png
        volume   "ESP"
        loader   /vmlinuz-'$kernel'
        initrd   /intel-ucode.img
        initrd   /initramfs-'$kernel'.img
        options  "cryptdevice=/dev/disk/by-partlabel/'$name_system':'$root_vol_name' root=/dev/mapper/'$root_vol_name' rootflags=subvol=root rw add_efi_memmap"
        submenuentry "Boot to terminal" {
            add_options "systemd.unit=multi-user.target"
        }
        enabled
    }
    ' >> /boot/EFI/refind/refind.conf
    sed -i 's/^#scanfor.*/scanfor manual,internal,external,optical/' /boot/EFI/refind/refind.conf
    sed -i 's/^timeout.*/timeout 3/' /boot/EFI/refind/refind.conf
fi

echo "############################################################"
echo "# crypttab"
echo "############################################################"
echo "$root_vol_name    /dev/disk/by-partlabel/$name_system    none                    luks,timeout=180" >> /etc/crypttab

rm -rfv $DIR/step2.sh $DIR/variables.sh
echo "############################################################"
echo "# Finished. Now type:"
echo "# exit"
echo "# shutdown now"
echo "############################################################"
exit