#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

unset CONFIGS
unset CONFIG_LIST
unset UPDATE
unset INSTALL_LIST
unset FONTS

CONFIG_LIST=()
INSTALL_LIST=()

echo -e "${GREEN}(H)yprland and all packages, (I)nstall just my selection of packages or (C)ancle" 
read decision

command_exists(){
   command -v $1 >/dev/null 2>&1;
} 

if decision == 'H'; then
    
    echo "Install everything needed..."
    INSTALL_LIST=("neovim" "pyhton3-neovim" "python3" "pyhton3-pip" "kitty" "ranger" "ninja-build" "cmake" "meson" "gcc-c++" "libxcb-devel" "libX11-devel" "pixman-devel" "wayland-protocols-devel" "cairo-devel" "pango-devel" "gdb" "wayland-devel" "rust" "cargo" "tldr")
    UPDATE=y
    CONFIGS=y
    FONTS=y

    for config in $(ls dotconfig); do
    CONFIG_LIST += ("${config}")
    done

    if [[ "${FONTS}" == "y" ]]; then
    for font in "fontawesome-fonts fontawesome-fonts-web"; do
        INSTALL_LIST+=("$font")
    done
    fi

    if [[ "${UPDATE}" == "y" ]]; then
    debug "Updating System..."
    debug "$(sudo dnf update -y)"
    fi

    if [[ "${CONFIGS}" == "y" ]]; then
    if [[ ! -d ~/.config ]]; then
        debug "Creating .config directory..."
        mkdir ~/.config
    fi
    debug "copying config files..."
    for config in ${CONFIG_LIST[@]}; do
        debug "${config}"
        cp -r ./dotconfig/${config} ~/.config
    done
    fi

    if [[ ${INSTALL_LIST} ]]; then
    debug "Installing all Packages..."
    debug "$(sudo dnf -y install ${INSTALL_LIST[@]})"
    debug "$(curl -sS https://starship.rs/install.sh | sh)"
    fi

    # Hyprland build 

    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    sudo make install

    # Implementing Eww (https://github.com/elkowar/eww)
