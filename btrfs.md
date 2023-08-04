From NixOS Wiki

 Jump to: [navigation](#mw-navigation), [search](#p-search) 

**btrfs** is a modern copy on write (CoW) filesystem for Linux aimed at implementing advanced features while also focusing on fault tolerance, repair and easy administration.

## Installation

 **Note:** The following example is for EFI enabled systems. Adjust commands accordingly for a BIOS installation.

### Partition the disk

# printf "label: gpt\n,550M,U\n,,L\n" | sfdisk /dev/sdX

### Format partitions and create subvolumes

# mkfs.fat -F 32 /dev/sdX1

# mkfs.btrfs /dev/sdX2
# mkdir -p /mnt
# mount /dev/sdX2 /mnt
# btrfs subvolume create /mnt/root
# btrfs subvolume create /mnt/home
# btrfs subvolume create /mnt/nix
# umount /mnt

### Mount the partitions and subvolumes

# mount -o compress=zstd,subvol=root /dev/sdX2 /mnt
# mkdir /mnt/{home,nix}
# mount -o compress=zstd,subvol=home /dev/sdX2 /mnt/home
# mount -o compress=zstd,noatime,subvol=nix /dev/sdX2 /mnt/nix

# mkdir /mnt/boot
# mount /dev/sdX1 /mnt/boot

### Install NixOS

# nixos-generate-config --root /mnt
# nano /mnt/etc/nixos/configuration.nix # manually add mount options
# nixos-install

## Configuration

### Compression

`nixos-generate-config --show-hardware-config` doesn't detect mount options automatically, so to enable compression, you must specify it and other mount options in a persistent configuration:

fileSystems = {
  "/".options = [ "compress=zstd" ];
  "/home".options = [ "compress=zstd" ];
  "/nix".options = [ "compress=zstd" "noatime" ];
  "/swap".options = [ "noatime" ];
};

### Swap file

Optionally, create a separate subvolume for the swap file. Be sure to regenerate your `hardware-configuration.nix` if you choose to do this.

# mkdir -p /mnt
# mount /dev/sdXY /mnt
# btrfs subvolume create /mnt/swap
# umount /mnt
# mkdir /swap
# mount -o subvol=swap /dev/sdXY /swap

Then, create the swap file with copy-on-write and compression disabled:

# truncate -s 0 /swap/swapfile
# chattr +C /swap/swapfile
# btrfs property set /swap/swapfile compression none
# dd if=/dev/zero of=/swap/swapfile bs=1M count=4096
# chmod 0600 /swap/swapfile
# mkswap /swap/swapfile

Finally, add the swap file to your configuration and `nixos-rebuild switch`:

swapDevices = [ { device = "/swap/swapfile"; } ];

## Usage

### Subvolume

Create a subvolume

btrfs subvolume create /mnt/nixos

Removing a subvolume

btrfs subvolume delete /mnt/nixos

### Snapshots

Taking a read-only (`-r`) snapshot called `nixos_snapshot_202302` of the subvolume mounted at `/` 

btrfs subvolume snapshot -r / /mnt/@nixos_snapshot_202302

Make snapshot read-write again

btrfs property set -ts /mnt/@nixos_snapshot_202302 ro false

List snapshots for `/` 

sudo btrfs subvolume list /

### Transfer snapshot

Sending the snapshot `/mnt/@nixos_snapshot_202302` compressed to a remote host via ssh at `root@192.168.178.110` and saving it to a subvolume mounted or directory at `/mnt/nixos` 

sudo btrfs send /mnt/@nixos_snapshot_202302 | zstd | ssh root@192.168.178.110 'zstd -d | btrfs receive /mnt/nixos'
