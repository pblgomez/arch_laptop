# arch_laptop

Based on (https://wiki.archlinux.org/index.php/User:Altercation/Bullet_Proof_Arch_Install#Installation_of_Base_Arch_Linux_System)[This article]

1. Boot the arch install media
    ```
    pacman -Sy git
    git clone http://github.com/pblgomez/arch_laptop.git
    ```
1. Change all the variables on variables.sh
    ```
    ./arch_laptop/step1.sh
    ```

1. Inside the arch-chroot
    ```
    /root/step2.sh
    ```