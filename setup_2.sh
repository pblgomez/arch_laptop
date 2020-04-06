sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
systemd-firstboot --prompt-locale
timedatectl set-ntp 1
timedatectl set-timezone Atlantic/Canary
hostnamectl set-hostname 'pbl-miair13'
echo "127.0.1.1	pbl-miair13.localdomain	pbl-miair13" >> /etc/hosts

echo "Base Package Installation"
pacman -Syu --needed --noconfirm linux-zen base-devel btrfs-progs iw gptfdisk zsh neovim terminus-font intel-ucode grub grub-btrfs

echo "Initramfs"
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.orig

sed -i 's/^HOOKS=.*/HOOKS=(base systemd sd-vconsole modconf keyboard block filesystems btrfs sd-encrypt fsck)/' /etc/mkinitcpio.conf

echo "KEYMAP=us-acentos" >> /etc/vconsole.conf
mkinitcpio -p linux-zen

echo "Bootloader"
btrfs_uuid=$(cat /root/uuid_de_crypto)
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=UUID='$btrfs_uuid':system"/' /etc/default/grub



# pacman -S refind-efi
# refind-install
# 
# cp /boot/EFI/refind/refind.conf /boot/EFI/refind/refind.conf.bak
# echo "use_graphics_for windows" >> /boot/EFI/refind/refind.conf
# echo "also_scan_dirs   +,@/             # Search for boot loaders in the specified directory" >> /boot/EFI/refind/refind.conf
# 
# uid_systema=$(cat /root/uuid_de_system)
# subvolumen_uuid=$(btrfs filesystem show system | grep uuid | awk '{print $4}'
# echo '"Boot with standard options"  "rd.luks.name=*FILL IN UUID FROM PARTITION*=cryptsystem root=UUID=*UUID FROM encrypted root subvolume* rootflags=subvol=root initrd=/intel-ucode.img initrd=/initramfs-linux.img"' >> /boot/refind_linux.conf
# 
# 
# echo "CUIDADO MIRA EL ULTIMO PASO"
# echo "despues reboot"
