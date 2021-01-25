# arch_laptop

Based on [This article](https://wiki.archlinux.org/index.php/User:Altercation/Bullet_Proof_Arch_Install#Installation_of_Base_Arch_Linux_System)

1. Boot the arch install media
    ```
    pacman -Sy git
    git clone https://github.com/pblgomez/arch_laptop.git
    ```
1. Change all the variables on variables.sh
    ```
    ./arch_laptop/step1.sh
    ```

1. Inside the arch-chroot
    ```
    /root/step2.sh
    ```
1. There's some scripts (that you should check first!) on /tmp/var/post
    ```
    /tmp/var/post/0000-RunAll.sh
    ```
