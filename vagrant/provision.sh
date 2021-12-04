#!/usr/bin/env bash

# Install lightweight desktop environment (XFCE4) and display manager (LightDM)
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y xfce4 firefox virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

# TODO: Remove gnome after install

# Install GNS3 Server and GUI
# Wireshark hack https://unix.stackexchange.com/q/367866
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
add-apt-repository ppa:gns3/ppa -y
apt-get update
apt-get install -y gns3-gui gns3-server

# Install Docker CE
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

# Add user to required groups
usermod -aG ubridge vagrant
usermod -aG libvirt vagrant
usermod -aG kvm vagrant
dpkg-reconfigure wireshark-common
usermod -aG wireshark vagrant
usermod -aG docker vagrant

# echo "autologin-user=vagrant" | tee -a /etc/lightdm/lightdm.conf
reboot