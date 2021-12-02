#!/usr/bin/env bash

# Add GNS3 PPA and update & upgrade package index
apt-add-repository multiverse -y
add-apt-repository ppa:gns3/ppa -y
apt-get update
apt-get upgrade -y

# Install XFCE desktop https://stackoverflow.com/a/53363591
apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config
apt-get install -y lightdm lightdm-gtk-greeter

# Install GNS3 GUI
export DEBIAN_FRONTEND=noninteractive
apt-get install -y gns3

# Reboot after installing
reboot