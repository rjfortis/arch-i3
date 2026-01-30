#!/bin/bash

sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm \
    xorg-server xorg-xinit \
    i3-wm i3status i3lock xss-lock

sudo pacman -S --needed --noconfirm \
    pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol \
    pamixer mesa spice-vdagent

sudo pacman -S --needed --noconfirm \
    alacritty xterm rofi feh lxappearance arandr \
    pcmanfm gvfs udiskie \
    dunst libnotify firefox chromium \
    scrot imv xclip

sudo pacman -S --needed --noconfirm \
    code docker docker-compose neovim git \
    ripgrep jq direnv htop curl wget rsync \
    zip unzip p7zip unrar bash-completion \
    xdg-user-dirs xdg-utils dbus xdg-desktop-portal-gtk \
    brightnessctl networkmanager network-manager-applet \
    xdotool dex polkit-gnome xrandr

sudo pacman -S --needed --noconfirm \
    ttf-dejavu ttf-font-awesome noto-fonts-emoji ttf-liberation \
    ttf-ubuntu-font-family ttf-jetbrains-mono

if ! command -v mise &> /dev/null; then
    curl https://mise.jdx.dev/install.sh | sh
fi

sudo systemctl enable docker.service
sudo usermod -aG docker $USER
sudo systemctl enable NetworkManager
xdg-user-dirs-update

echo "--------------------------------------------------"
echo "Installation complete."
echo "REMEMBER: Restart your session for Docker group changes to take effect."
echo "--------------------------------------------------"
