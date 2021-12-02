#!/usr/bin/env bash

# Update package index and upgrade packages
export DEBIAN_FRONTEND=noninteractive
add-apt-repository ppa:gns3/ppa -y
apt-get update
apt-get upgrade -y

# Install minimal desktop
apt-get install lubuntu-desktop -y

# Reboot after installing GUI
reboot