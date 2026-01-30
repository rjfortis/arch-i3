#!/bin/bash

# --- 0. Pre-flight Checks ---

# Internet validation
echo "Checking internet connection..."
if ! ping -c 3 google.com > /dev/null 2>&1; then
    echo "ERROR: No internet connection."
    exit 1
fi

# UEFI Validation
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

# Confirm before destroying data
read -p "WARNING: All data on /dev/$DRIVE_NAME will be erased. Continue? (y/n): " CONFIRM
[ "$CONFIRM" != "y" ] && exit 1

# Determine partition naming
if [[ $DRIVE_NAME == nvme* ]]; then
    PART_BOOT="/dev/${DRIVE_NAME}p1"
    PART_ROOT="/dev/${DRIVE_NAME}p2"
else
    PART_BOOT="/dev/${DRIVE_NAME}1"
    PART_ROOT="/dev/${DRIVE_NAME}2"
fi

# --- 2. Partitioning & Mounting ---
echo "Partitioning /dev/$DRIVE_NAME..."
wipefs -a "/dev/$DRIVE_NAME"

# Partitioning with sfdisk (512MB EFI, Rest Root)
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sfdisk "/dev/$DRIVE_NAME"
  label: gpt
  size=512M, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
  type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
EOF

partprobe "/dev/$DRIVE_NAME"
sleep 3

echo "Formatting partitions..."
mkfs.fat -F 32 "$PART_BOOT"
mkfs.ext4 "$PART_ROOT"

mount "$PART_ROOT" /mnt
mount --mkdir "$PART_BOOT" /mnt/boot

# --- 3. Pacstrap (Base + VM Essentials) ---
# Added qemu-guest-agent for VM performance/management
pacstrap -K /mnt base linux linux-firmware nano networkmanager sudo git qemu-guest-agent

# --- 4. Fstab ---
genfstab -U /mnt >> /mnt/etc/fstab

# --- 5. Chroot Configuration ---
arch-chroot /mnt <<EOF
# Localization
ln -sf /usr/share/zoneinfo/America/El_Salvador /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Networking
echo "$MY_HOSTNAME" > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $MY_HOSTNAME.localdomain   $MY_HOSTNAME
EOT

# Passwords (Non-interactive)
echo "root:$MY_PASSWORD" | chpasswd
useradd -m -G wheel "$MY_USER"
echo "$MY_USER:$MY_PASSWORD" | chpasswd

# Sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Bootloader
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable Services
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
