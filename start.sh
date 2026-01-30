#!/bin/bash

# BASE_URL="https://raw.githubusercontent.com/rjfortis/arch-mini/main"
BASE_URL="https://raw.githubusercontent.com/rjfortis/arch-i3/refs/heads/main"


echo "Starting Arch Linux Setup..."

# 1. Run Installation (Non-interactive)
echo "Running init.sh..."
curl -sL "${BASE_URL}/init.sh" | bash

# 2. Run System Configuration (Non-interactive)
echo "Running config.sh..."
curl -sL "${BASE_URL}/config.sh" | bash

# 3. Run LazyVim Setup (Non-interactive)
echo "Running lazyvim.sh..."
curl -sL "${BASE_URL}/lazyvim.sh" | bash

# 4. Download Dotfiles
echo "Downloading application configs..."
curl -sL "${BASE_URL}/i3/config" -o ~/.config/i3/config
curl -sL "${BASE_URL}/alacritty/alacritty.toml" -o ~/.config/alacritty/alacritty.toml

# 5. Run Git & SSH Setup (Interactive)
echo "Running git-ssh.sh..."
curl -sL "${BASE_URL}/git-ssh.sh" | bash

echo "--------------------------------------------------"
echo "All scripts executed successfully."
echo "Please reboot your system to enter i3."
echo "--------------------------------------------------"
