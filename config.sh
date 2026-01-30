#!/bin/bash

mkdir -p ~/.config/i3 ~/.config/alacritty ~/.config/picom ~/.config/dunst
mkdir -p ~/Downloads ~/Documents ~/Pictures ~/Videos ~/Music ~/Desktop

sudo localectl set-x11-keymap us
sudo timedatectl set-timezone America/El_Salvador
sudo timedatectl set-ntp true

cat <<EOF > ~/.xinitrc
#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "\$f" ] && . "\$f"
  done
  unset f
fi

xrandr --output Virtual-1 --mode 1920x1080

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
dex -a -s /etc/xdg/autostart:~/.config/autostart &
nm-applet &
spice-vdagent &
picom -b &
udiskie -t &
xsetroot -cursor_name left_ptr &

exec i3
EOF

chmod +x ~/.xinitrc

cat <<EOF > ~/.bash_profile
export PATH="\$HOME/.local/bin:\$PATH"
export EDITOR="nvim"
export VISUAL="code"

if command -v mise &> /dev/null; then
  eval "\$(~/.local/bin/mise activate bash)"
fi

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
EOF

systemctl --user --now enable pipewire pipewire-pulse wireplumber

echo "--------------------------------------------------"
echo "Configuration complete."
echo "Timezone: America/El_Salvador"
echo "Keyboard: US"
echo "Resolution: 1920x1080 (Virtual-1)"
echo "--------------------------------------------------"
