#!/bin/bash

# Backup existing config if it exists
if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak
fi

# Clone the starter
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Wait for git clone to finish properly
sleep 2

# Remove git history from the starter
rm -rf ~/.config/nvim/.git

# Ensure config directory exists
mkdir -p ~/.config/nvim/lua/config

# Custom Keymaps
KEYMAPS_FILE="$HOME/.config/nvim/lua/config/keymaps.lua"

cat <<'EOF' >> "$KEYMAPS_FILE"

-- Custom buffer navigation
vim.keymap.set("n", "<S-Right>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Left>", ":bprevious<CR>", { desc = "Previous buffer" })
EOF

echo "LazyVim installed successfully."
