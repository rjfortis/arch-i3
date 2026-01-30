#!/bin/bash

# --- 0. Pre-flight Checks ---
echo "Checking internet connection..."
if ! ping -c 3 google.com > /dev/null 2>&1; then
    echo "ERROR: No internet connection."
    exit 1
fi

if [ ! -d "/sys/firmware/efi/efivars" ]; then
    echo "ERROR: System is not booted in UEFI mode."
    exit 1
fi

# --- 1. User Inputs ---
lsblk
echo "--------------------------------------------------"
read -p "Enter the drive name (e.g., sda, vda): " DRIVE_NAME
if [ ! -b "/dev/$DRIVE_NAME" ]; then
    echo "ERROR: Device /dev/$DRIVE_NAME not found."
    exit 1
fi

read -p "Enter hostname: " MY_HOSTNAME
read -p "Enter username: " MY_USER
read -s -p "Enter password for both root and $MY_USER: " MY_PASSWORD
echo ""

read -p "WARNING: All data on /dev/$DRIVE_NAME will be erased. Continue? (y/n): " CONFIRM
[ "$CONFIRM" != "y" ] && exit 1

# Detect partition naming before partitioning
if [[ $DRIVE_NAME == nvme* ]]; then
    PART_BOOT="/dev/${DRIVE_NAME}p1"
    PART_ROOT="/dev/${DRIVE_NAME}p2"
else
    PART_BOOT="/dev/${DRIVE_NAME}1"
    PART_ROOT="/dev/${DRIVE_NAME}2"
fi

# --- 2. Partitioning & Mounting ---
echo "Cleaning /dev/$DRIVE_NAME..."
wipefs -a "/dev/$DRIVE_NAME"

echo "Partitioning /dev/$DRIVE_NAME..."
# Using a simplified sfdisk syntax for better compatibility
sfdisk "/dev/$DRIVE_NAME" << EOF
label: gpt
unit: sectors

$PART_BOOT : size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
$PART_ROOT : type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
EOF

if [ $? -ne 0 ]; then
    echo "ERROR: Partitioning failed."
    exit 1
fi

partprobe "/dev/$DRIVE_NAME"
sleep 2

echo "Formatting partitions..."
mkfs.fat -F 32 "$PART_BOOT" || exit 1
mkfs.ext4 -F "$PART_ROOT" || exit 1

echo "Mounting partitions..."
mount "$PART_ROOT" /mnt || exit 1
mount --mkdir "$PART_BOOT" /mnt/boot || exit 1

if ! mountpoint -q /mnt; then
    echo "ERROR: /mnt is not a mountpoint."
    exit 1
fi

# --- 3. Pacstrap ---
pacstrap -K /mnt base linux linux-firmware nano networkmanager sudo git qemu-guest-agent || exit 1

# --- 4. Fstab ---
genfstab -U /mnt >> /mnt/etc/fstab

# --- 5. Chroot Configuration ---
arch-chroot /mnt <<EOF
ln -sf /usr/share/zoneinfo/America/El_Salvador /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$MY_HOSTNAME" > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $MY_HOSTNAME.localdomain   $MY_HOSTNAME
EOT

echo "root:$MY_PASSWORD" | chpasswd
useradd -m -G wheel "$MY_USER"
echo "$MY_USER:$MY_PASSWORD" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable qemu-guest-agent
EOF

echo "--------------------------------------------------"
echo "Base installation complete!"
echo "Rebooting in 5 seconds..."
echo "--------------------------------------------------"
sleep 5
umount -R /mnt
reboot
