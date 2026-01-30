#!/bin/bash

# User input
read -p "Enter your full name for Git: " shellname
read -p "Enter your email for Git & SSH: " shellemail

# Git configuration
git config --global user.name "$shellname"
git config --global user.email "$shellemail"
git config --global init.defaultBranch main

# Ensure .ssh directory exists with correct permissions
# mkdir -p ~/.ssh
# chmod 700 ~/.ssh

# SSH Key generation (non-interactive)
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "$shellemail" -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "SSH key already exists. Skipping generation."
fi

# Start ssh-agent and add the key
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

# Output result
echo "--------------------------------------------------"
echo "Git and SSH configuration complete."
echo "Your public key is:"
echo ""
cat "$HOME/.ssh/id_ed25519.pub"
echo ""
echo "Copy the key above and add it to your GitHub/GitLab settings."
echo "--------------------------------------------------"
