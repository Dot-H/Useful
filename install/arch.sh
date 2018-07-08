#!/bin/sh

# Good link: https://gist.github.com/heppu/6e58b7a174803bc4c43da99642b6094b
# UEFI mode enabled on UEFI motherboard
# LUKS encrypted partition
# 70G swap
# 150G root
# Remaining home

loadkeys uk

# TODO automaticrestard dhcpcd service
[ ping archlinux.org ] || 1>&1 echo 'No internet connection' && exit 1

timedatectl set-ntp true

Partition disk
--------------

DISK=/dev/sdb
BOOT_PARTITION=/dev/sdb2
LUKS_PARTITION=/dev/sdb3

# Create 2 partitions, one for boot partition and one for LUKS encrypted
# partition
gdisk $DISK
> n # Create partition
>  # default number
>  # default start
> +512M # 512M in size
> ef00 # EFI System

> n # Create partition
>  # default number
>  # default start
>  # Max size
>  # Linux fs

> w # Write on the disk


Format, encrypt
---------------

mkfs.vfat -F32 $BOOT_PARTITION
cryptsetup -v luksFormat $LUKS_PARTITION
cryptsetup luksOpen $LUKS_PARTITION luks

pvcreate /dev/mapper/luks # Create physical volume
vgcreate vg0 /dev/mapper/luks
lvcreate -L 70G vg0 -n swap
lvcreate -L 150G vg0 -n root
lvcreate -l +100%FREE vg0 -n home

mkfs.ext4 /dev/mapper/vg0-root
mkfs.ext4 /dev/mapper/vg0-home
mkswap /dev/mapper/vg0-swap

mount /dev/mapper/vg0-root /mnt
swapon /dev/mapper/vg0-swap

mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot


Install base system
-------------------

pacstrap /mnt base base-devel
genfstab -pU /mnt >> /mnt/etc/fstab

Prepare new system
------------------

HOSTNAME=toto
USERNAME=doth

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1	localhost
::1		localhost
127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME" > /etc/hosts

echo '## Cloudflare
nameserver 1.1.1.1
# IPv6
nameserver 2606:4700:4700::1111,2606:4700:4700::1001

nameserver 8.8.8.8' > /etc/resolv.conf

pacman -S dialog wpa_supplicant vim reflector openssh zsh

passwd
useradd -m -G wheel -s /usr/bin/zsh doth
#TODO Uncomment sudo rights to wheels /etc/sudoers
passwd doth

# Select the 200 most recently synchronized HTTP or HTTPS mirrors, sort them
# by download speed, and overwrite the file /etc/pacman.d/mirrorlist
reflector --latest 200 --protocol http --protocol https --sort rate \
          --save /etc/pacman.d/mirrorlist

Locales
-------

echo LANG=en_GB.UTF-8 > /etc/locale.conf
# Uncomment $LANG in /etc/locale.gen
echo KEYMAP=uk > /etc/vconsole.conf
locale-gen


mkinitcpio
----------

bootctl --path=/boot install
# edit /etc/mkinitcpio.conf
# MODULES="ext4"
# .
# .
# .
# HOOKS="base udev autodetect modconf block keymap encrypt lvm2 resume \
#        filesystems keyboard fsck"

echo "title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options cryptdevice=UUID=$(blkid -s UUID -o value $LUKS_PARTITION)\
:lvm:allow-discards resume=/dev/mapper/vg0-swap root=/dev/mapper/vg0-root \
rw quiet" \
    > /boot/loader/entries/arch.conf

echo 'timeout 20
default arch
editor 0' > /boot/loader/loader.conf

mkinitcpio -p linux
exit
umount -R /mnt
reboot


Service
-------

systemctl enable dhcpcd.service

Yaourt
------

sudo pacman -S git
cd /tmp
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd ..
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si
cd


git clone https://github.com/Dot-H/Useful
# /!\ Link dotfiles from Useful /!\

Terminal
-----

pacman -S rxvt-unicode


i3
--

pacman -S xorg xorg-xinit i3 dmenu
# link .xinitrc .zprofile .Xressources .zshrc
startx
