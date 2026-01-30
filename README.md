# Arch Linux VM Automated Setup 🚀

This repository contains a suite of scripts to automate the installation and configuration of a minimal **Arch Linux** environment, specifically optimized for **Virtual Machines (VMs)** and **Testing Environments**.

> [!WARNING]
> **FOR TESTING PURPOSES ONLY.** These scripts are destructive and will format the target drive without manual partitioning. Do not use on hardware containing important data.

## 🛠️ System Architecture

The setup is divided into two main stages:

1. **Base Installation**: Disk partitioning (UEFI), base system, and bootloader.
2. **User Configuration**: Desktop environment (i3wm), development tools (Docker, Neovim, Mise), and dotfiles.

---

## 🚀 How to Use

### Step 1: Base Installation (From Arch ISO)

Boot your VM using the official Arch Linux ISO. Once you have a prompt, run:

```bash

curl -LO https://raw.githubusercontent.com/rjfortis/arch-i3/refs/heads/main/arch.sh
bash arch.sh

```

The script will:

* Verify UEFI and Internet connection.
* Partition your disk (512MB EFI / Rest Root).
* Install the base system and **QEMU Guest Agent**.
* Configure users, passwords, and GRUB.
* **Reboot automatically.**

---

### Step 2: Post-Install Configuration

After the reboot, login with your new user and execute the orchestrator:

```bash

curl -LO https://raw.githubusercontent.com/rjfortis/arch-i3/refs/heads/main/start.sh
bash start.sh

```

---

## 📦 What's included?

| Script | Description |
| --- | --- |
| `arch.sh` | Disk formatting, UEFI/GPT setup, and Base Arch install. |
| `start.sh` | Orchestrator that triggers all sub-scripts and downloads dotfiles. |
| `init.sh` | Installs Xorg, i3wm, Alacritty, Firefox, Docker, and Fonts. |
| `config.sh` | System tweaks: Keyboard (US), Timezone (SV), and Xinitrc. |
| `lazyvim.sh` | Clones LazyVim starter and adds custom buffer keymaps. |
| `git-ssh.sh` | Interactive setup for Git credentials and Ed25519 SSH keys. |

## 🖥️ Key Components

* **Window Manager**: i3wm (Tokyo Night Theme).
* **Terminal**: Alacritty (JetBrains Mono).
* **Editor**: Neovim (LazyVim).
* **Dev Tools**: Docker, Mise (Runtime manager), Git, and Ripgrep.

---

## 🛠️ Customization

To use your own settings, fork this repository and update the `BASE_URL` variable in `start.sh` to point to your username:

```bash
BASE_URL="https://raw.githubusercontent.com/YOUR_USERNAME/REPO/refs/heads/main"

```
