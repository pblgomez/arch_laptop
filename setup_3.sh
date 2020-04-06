#!/usr/bin/env bash


grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
