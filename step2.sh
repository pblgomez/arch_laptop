#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/variables.sh

# echo "############################################################"
# echo "# Password for root:"
# echo "############################################################"

echo "############################################################"
echo "# Create user"
echo "############################################################"
pacman -Syu --noconfirm zsh
read -p "Enter username: " username
useradd -G sys,network,scanner,power,rfkill,users,video,uucp,storage,optical,lp,audio,wheel -s $(which zsh) -m $username
echo "Enter password:"
passwd $username
# Give sudoers permission
sed -i 's/# %w.*) ALL$/%wheel ALL=(ALL) ALL/g' /etc/sudoers
# Disable root permission
sed -i '/^root.*/ s/:x:/: :/' /etc/passwd


echo "############################################################"
echo "# Install programs"
echo "############################################################"
pacman -Syu --noconfirm \
  btrfs-progs ntp \
  $kernel $kernel-headers linux-firmware intel-ucode dkms \
  neovim openssh git python \
  wpa_supplicant networkmanager \
  efibootmgr
  # dhcpcd


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
echo "127.0.0.1       localhost\n
::1       localhost\n
127.0.1.1     $set_hostname.localdomain   $set_hostname" >> /etc/hosts
systemctl enable NetworkManager
#systemctl enable dhcpcd
systemctl enable sshd
systemctl enable ntpd

echo "############################################################"
echo "# makepkg.conf"
echo "############################################################"
sed 's/#MAKEFLAGS.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

echo "############################################################"
echo "# Bootloader"
echo "############################################################"
if [ $bootloader = "grub" ]; then
    echo "############################################################"
    echo "# GRUB"
    echo "############################################################"
    pacman -Sy grub grub-btrfs grub-theme-vimix --noconfirm
    sed -i '/^#GRUB_ENABLE_CRYPTO.*/s/^#//' /etc/default/grub
    sed -i 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=3/' /etc/default/grub
    sed -i 's+GRUB_CMDLINE_LINUX=.*+GRUB_CMDLINE_LINUX="cryptdevice=/dev/disk/by-partlabel/'$name_system':'${root_vol_name}' root=/dev/mapper/'$root_vol_name'"+' /etc/default/grub
    sed -i 's+.*GRUB_THEME.*+GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"+' /etc/default/grub
    cp -r /usr/share/grub/themes/Vimix /boot/grub/themes/
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
echo "# Install plymouth"
echo "############################################################"
pacman -Sy libdrm pango docbook-xsl --noconfirm
sudo -u nobody git clone https://aur.archlinux.org/plymouth.git /var/tmp/plymouth
cd /var/tmp/plymouth
sudo -u nobody makepkg
pacman -U plymouth*.zst
cd ~
sed -i 's/.*Theme.*/Theme=bgrt/' /etc/plymouth/plymouthd.conf
sed -i 's/^GRUB_CMD.*ULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"/' /etc/default/grub

echo "############################################################"
echo "# mkinitcpio"
echo "############################################################"
sed -i 's/^MODULES=.*/MODULES=( i915? vboxvideo? )/' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base udev plymouth plymouth-encrypt autodetect modconf block filesystems keyboard fsck)/' /etc/mkinitcpio.conf
sed -i '/#COMPRESSION="zstd"/s/^#//g' /etc/mkinitcpio.conf
mkinitcpio -p $kernel


echo "############################################################"
echo "# crypttab"
echo "############################################################"
echo "$root_vol_name    /dev/disk/by-partlabel/$name_system    none                    luks,timeout=180" >> /etc/crypttab

rm -rfv $DIR/step2.sh $DIR/variables.sh
echo "############################################################"
echo "# Finished. Now type:"
echo "# exit"
echo "############################################################"
exit
eval exit
