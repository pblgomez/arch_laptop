#!/usr/bin/env bash


grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
