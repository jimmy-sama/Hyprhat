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

command_exists () {
    command -v $1 >/dev/null 2>&1;
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${RED}To run me, you need: ${REQUIREMENTS}${RC}"
        exit 1
    fi
    ## Check if the current directory is writable
    GITPATH="$(dirname "$(realpath "$0")")"
    if [[ ! -w ${GITPATH} ]]; then
      echo -e "${RED}Can't write to ${GITPATH}${RC}"
      exit 1
   fi
    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep ${sug}; then
            SUGROUP=${sug}
            echo -e "Super user group ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep ${SUGROUP} >/dev/null; then
        echo -e "${RED}You need to be a member of the sudo group to run me!"
        exit 1
    fi
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='autojump bash bash-completion tar neovim'
    echo -e "${YELLOW}Installing dependencies...${RC}"
   sudo dnf install -yq ${DEPENDENCIES}
}

installStarship(){
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh|sh;then
        echo -e "${RED}Something went wrong during starship install!${RC}"
        exit 1
    fi
}

linkConfig() {
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]]; then
        echo -e "${YELLOW}Moving old bash config file to ${HOME}/.backup${RC}"
        if ! mv ${OLD_BASHRC} ${HOME}/.bashrc.bak; then
            echo -e "${RED}Can't move the old bash config file!${RC}"
            exit 1
        fi
    fi

    echo -e "${YELLOW}Linking new bash config file...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/dotconfig/.bashrc ${HOME}/.bashrc
    ln -svf ${GITPATH}/dotconfig/starship.toml ${HOME}/.config/starship.toml

    ## Check if ranger config directory is already there.
    OLD_RANGER="${HOME}/.config/ranger"
    if [[ -e ${OLD_RANGER} ]]; then
      echo -e "${YELLOW}Moving old ranger config directory to ${HOME}/.backup${RC}"
      if ! mv "${OLD_RANGER} ${HOME}/.backup"; then
         echo -e "${$RED}Can't move the old ranger config directory!${RC}"
         exit 1
      fi
   fi

    echo -e "${YELLOW}Linking new ranger config directory...${RC}"
    ## Make symbolic link.
    ln -svf ${GITPATH}/dotconfig/ranger/* ${HOME}/.config/ranger/
    ## Allow previewing files as root change this file => /usr/lib/python3.11/site-packages/ranger/core/main.py
      #  if fm.username == 'root':
      #          fm.settings.preview_files = False
      #          fm.settings.use_preview_script = False
      #          fm.log.appendleft("Running as root, disabling the file previews.")
}


debug "Install everything needed..."
INSTALL_LIST=("neovim" "pyhton3-neovim" "python3" "pyhton3-pip" "kitty" \
"ranger" "ninja-build" "cmake" "meson" "gcc-c++" "libxcb-devel" "libX11-devel" \
"pixman-devel" "wayland-protocols-devel" "cairo-devel" "pango-devel" "gdb" \
"rust" "cargo" "tldr" "zsh")
UPDATE=y
CONFIGS=y
FONTS=y

echo "defaultyes=True\nmax_parallel_downloads=6\nfastestmirror=1" >> /etc/dnf/dnf.conf

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
