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

parted /dev/vda -- mklabel gpt

parted /dev/vda -- mkpart ESP fat32 2MB 629MB

parted /dev/vda -- set 1 esp on

parted /dev/vda -- mkpart primary 630MB 100%

cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash sha512 --iter-time 5000 --key-size 256 --pbkdf argon2id --use-random --verify-passphrase /dev/vda2

cryptsetup luksOpen /dev/vda2 crypted-nixos

mkfs.fat -F 32 -n ESP /dev/vda1

mkfs.btrfs -L crypted-nixos /dev/mapper/crypted-nixos

mount /dev/mapper/crypted-nixos /mnt  # create-btrfs

btrfs subvolume create /mnt/@nix  

btrfs subvolume create /mnt/@guix  

btrfs subvolume create /mnt/@tmp

btrfs subvolume create /mnt/@swap

btrfs subvolume create /mnt/@persistent

btrfs subvolume create /mnt/@snapshots

umount /mnt

mkdir /mnt/{nix,gnu,tmp,swap,persistent,snapshots,boot}  # mount-1

mount -o compress-force=zstd:1,noatime,subvol=@nix /dev/mapper/crypted-nixos /mnt/nix

mount -o compress-force=zstd:1,noatime,subvol=@guix /dev/mapper/crypted-nixos /mnt/gnu

mount -o compress-force=zstd:1,subvol=@tmp /dev/mapper/crypted-nixos /mnt/tmp

mount -o subvol=@swap /dev/mapper/crypted-nixos /mnt/swap

mount -o compress-force=zstd:1,noatime,subvol=@persistent /dev/mapper/crypted-nixos /mnt/persistent

mount -o compress-force=zstd:1,noatime,subvol=@snapshots /dev/mapper/crypted-nixos /mnt/snapshots

mount /dev/vda1 /mnt/boot

btrfs filesystem mkswapfile --size 96g --uuid clear /mnt/swap/swapfile

lsattr /mnt/swap

swapon /mnt/swap/swapfile



