# arch_laptop

Based on (https://wiki.archlinux.org/index.php/User:Altercation/Bullet_Proof_Arch_Install#Installation_of_Base_Arch_Linux_System)[This article]

1. Boot the arch install media
    ```
    pacman -Sy git
    git clone http://github.com/pblgomez/arch_laptop.git
    ./arch_laptop/setup.sh
    ```

1. Inside the systemd env
    ```
    ./arch_laptop/setup_2.sh
    ```

1. Bootloader
    ```
    arch-chroot /mnt
    /root/arch_laptop/setup_3.sh
    ```
