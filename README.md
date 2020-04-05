# arch_laptop




```
lsblk -o +LABEL,PARTLABEL,UUID,PARTUUID
DRIVE=/dev/sda
sgdisk --zap-all $DRIVE
sgdisk --clear \
         --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=2:0:+8GiB   --typecode=2:8200 --change-name=2:cryptswap \
         --new=3:0:0       --typecode=3:8300 --change-name=3:cryptsystem \
           $DRIVE
```
## Format EFI Partition
```
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
```

## Encrypt System Partition
```
cryptsetup luksFormat --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/cryptsystem
cryptsetup open /dev/disk/by-partlabel/cryptsystem system
```

## Bring Up Encrypted Swap
```
cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap
mkswap -L swap /dev/mapper/swap
swapon -L swap
```
