#!/usr/bin/env bash

# Install lightweight desktop environment (XFCE4)
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y xfce4 firefox virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

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

# Copy GDM3 autologin config
# cp /vagrant/gdm3.conf /etc/gdm3/custom.conf

# Create GNS3 config folder if it does not exist and change owner, group to vagrant
mkdir -p /home/vagrant/.config/GNS3/2.2
chown -R vagrant:vagrant /home/vagrant/.config/GNS3
# Copy over GNS3 config files
cp /vagrant/gns3_gui.conf /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
cp /vagrant/gns3_server.conf /home/vagrant/.config/GNS3/2.2/gns3_server.conf

# Reboot due to GUI install
reboot