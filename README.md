<h2 align="center">:snowflake: Ryan4Yin's Nix Config :snowflake:</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<p align="center">
	<a href="https://github.com/ryan4yin/nix-config/stargazers">
		<img alt="Stargazers" src="https://img.shields.io/github/stars/ryan4yin/nix-config?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-24.05-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://github.com/ryan4yin/nixos-and-flakes-book">
        <img src="https://img.shields.io/static/v1?label=Nix Flakes&message=learning&style=for-the-badge&logo=nixos&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41"></a>
  </a>
</p>

sudo su

parted /dev/sda -- mklabel gpt

parted /dev/sda -- mkpart ESP fat32 2MB 849MB

parted /dev/sda -- set 1 esp on

parted /dev/sda -- mkpart primary 850MB 100%

--------------------------------------------------

cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash sha512 --iter-time 5000 --key-size 256 --pbkdf argon2id --use-random --verify-passphrase /dev/sda3

cryptsetup luksOpen /dev/sda3 OS

--------------------------------------------------

mkfs.fat -F 32 -n ESP /dev/sda1

mkfs.btrfs -L OS /dev/mapper/OS

mount /dev/mapper/OS /mnt  # create-btrfs

btrfs subvolume create /mnt/@nix 

btrfs subvolume create /mnt/@cachyos

btrfs subvolume create /mnt/@guix  

btrfs subvolume create /mnt/@tmp

btrfs subvolume create /mnt/@swap

btrfs subvolume create /mnt/@persistent

btrfs subvolume create /mnt/@snapshots

umount /mnt

mkdir /mnt/{cachyos,nix,gnu,tmp,swap,persistent,snapshots,boot}  # mount-1

mount -o compress-force=zstd:1,noatime,subvol=@cachyos /dev/mapper/OS /mnt/cachyos

mount -o compress-force=zstd:1,noatime,subvol=@nix /dev/mapper/OS /mnt/nix

mount -o compress-force=zstd:1,noatime,subvol=@guix /dev/mapper/OS /mnt/gnu

mount -o compress-force=zstd:1,subvol=@tmp /dev/mapper/OS /mnt/tmp

mount -o subvol=@swap /dev/mapper/OS /mnt/swap

mount -o compress-force=zstd:1,noatime,subvol=@persistent /dev/mapper/OS /mnt/persistent

mount -o compress-force=zstd:1,noatime,subvol=@snapshots /dev/mapper/OS /mnt/snapshots

mount /dev/sda1 /mnt/boot

btrfs filesystem mkswapfile --size 4g --uuid clear /mnt/swap/swapfile

lsattr /mnt/swap

swapon /mnt/swap/swapfile

lsblk

-----------------------------------------------------------



