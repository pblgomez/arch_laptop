#!/usr/bin/env bash
set -e

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
systemd-firstboot --prompt-locale
timedatectl set-ntp 1
timedatectl set-timezone Atlantic/Canary
hostnamectl set-hostname 'pbl-miair13'
echo "127.0.1.1	pbl-miair13.localdomain	pbl-miair13" >> /etc/hosts

echo "Base Package Installation"
pacman -Syu --needed --noconfirm linux-zen base-devel btrfs-progs iw gptfdisk zsh neovim terminus-font intel-ucode grub grub-btrfs efibootmgr

echo "Initramfs"
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.orig

sed -i 's/^HOOKS=.*/HOOKS=(base systemd sd-vconsole modconf keyboard block filesystems btrfs sd-encrypt fsck)/' /etc/mkinitcpio.conf

echo "KEYMAP=us-acentos" >> /etc/vconsole.conf
mkinitcpio -p linux-zen

echo "Bootloader"
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
btrfs_uuid=$(cat /root/uuid_de_crypto)
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=UUID='$btrfs_uuid':system"/' /etc/default/grub

shutdown -P now
