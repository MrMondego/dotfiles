#!/bin/bash

sddm_theme_script="sddm_astronaunt_theme.sh"

# Asus TUF, set battery charge limit
sudo paru -Sy rog-control-center 
asusctl -c 60
asusctl aura rainbow-cycle

# Set max monitor brightness
sudo pacman -Sy --noconfirm brightnessctl
brightnessctl s 100%

echo "Hyprland and other"
sudo pacman -Sy --noconfirm --needed --disable-download-timeout ghostty neovim sddm hyprland rofi-wayland hyprpaper dunst
sudo pacman -Sy --noconfirm --needed --disable-download-timeout telegram-desktop snapper xdg-desktop-portal-hyprland wl-clipboard wl-clip-persist grimblast waybar wlogout udiskie hyprpolkitagent
paru -Sy qimgv-git # Image viewer
echo "Gambling"
sudo pacman -Sy --noconfirm --needed --disable-download-timeout proton-cachyos protontricks steam steam-native-runtime

systemctl --user enable --now hyprpolkitagent.service
asusctl profile -P Balanced

if [[ -e "$sddm_theme_script" ]]; then
  source $sddm_theme_script
fi

# Create snapshot
if [[ $1 == "--backup" ]]; then
  echo "Creating snapshot with snapper"
  sudo snapper -c root create-config / --description 'Post installation'
  sudo snapper list
fi

echo "Done. Starting SDDM..."
sleep 10

sudo systemctl enable sddm.service
sudo systemctl start sddm.service
