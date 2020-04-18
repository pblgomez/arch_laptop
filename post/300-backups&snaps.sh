#!/usr/bin/env bash
set -e

root_vol_name="system"
distro="arch"
root_vol_name="system"

if ! hash snapper 2>/dev/null; then
  echo "----------------------------------------------------------------------"
  echo "     Installing dependencies"
  echo "----------------------------------------------------------------------"
  yay -S --needed --noconfirm snapper snap-pac snap-pac-grub
  # Create the configs for root and home and delete folders
  sudo snapper -c root create-config / \
    && sudo btrfs subvolume delete /.snapshots \
    && sudo mkdir /.snapshots
  sudo snapper -c home create-config /home \
    && sudo btrfs subvolume delete /home/.snapshots \
    && sudo mkdir /home/.snapshots

  # Create the GOOD subvolumes
  sudo mount /dev/mapper/system /mnt
  sudo btrfs subvolume create /mnt/@snapshot_arch_root
  sudo btrfs subvolume create /mnt/@snapshot_arch_home
  sudo umount /mnt

  # Mount the subvolumes to the snapper mount point
  o_btrfs=defaults,x-mount.mkdir,compress=lzo,ssd,noatime
  sudo mount -o subvol=@snapshot_${distro}_root,$o_btrfs /dev/mapper/$root_vol_name /.snapshots/
  sudo mount -o subvol=@snapshot_${distro}_home,$o_btrfs /dev/mapper/$root_vol_name /home/.snapshots/

  # Activate service
  sudo systemctl start snapper-timeline.timer snapper-cleanup.timer
  sudo systemctl enable snapper-timeline.timer snapper-cleanup.timer

  # Populate fstab
  id_snapshot_root=$(sudo btrfs sub list / | grep @snapshot_arch_root$ | awk '{print$2}')
  id_snapshot_home=$(sudo btrfs sub list / | grep @snapshot_arch_home$ | awk '{print$2}')
  echo "LABEL=archroot        /.snapshots        btrfs      discard,rw,noatime,compress=lzo,ssd,space_cache,subvolid=$id_snapshot_root,subvol=/@snapshot_arch_root, 0 0" | sudo tee -a /etc/fstab
  echo "LABEL=archroot      	/home/.snapshots   btrfs     	discard,rw,noatime,compress=lzo,ssd,space_cache,subvolid=$id_snapshot_home,subvol=/@snapshot_arch_home,	0 0" | sudo tee -a /etc/fstab
fi