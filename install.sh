#!/usr/bin/env bash

INSTALL_LIST=("neovim" "pyhton3-neovim" "python3" "pyhton3-pip" "kitty" "ranger")

echo "defaultyes=True\nmax_parallel_downloads=6\nfastestmirror=1" >> /etc/dnf/dnf.conf

debug "Updating System"
debug "$(sudo dnf update -y)"

