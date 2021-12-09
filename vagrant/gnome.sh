#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Add all required PPAs before updating index
add-apt-repository ppa:gns3/ppa -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update apt index and upgrade any packages that need upgrading
apt-get update
apt-get upgrade -y

# Install vanilla GNOME shell desktop
apt-get install -y gnome-session gnome-terminal
apt-get install -y nautilus firefox --no-install-recommends

# Disable lock screen, screen saver, idle lock
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# Install GNS3 Server and GUI | Wireshark hack: https://unix.stackexchange.com/q/367866
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
apt-get install -y gns3-gui gns3-server

# Install Docker CE
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
apt-get install -y docker-ce

# Add user to required groups
usermod -aG ubridge vagrant
usermod -aG libvirt vagrant
usermod -aG kvm vagrant
# dpkg-reconfigure wireshark-common
usermod -aG wireshark vagrant
usermod -aG docker vagrant

# Enable vagrant user autologin
cp /vagrant/gdm3.conf /etc/gdm3/custom.conf

# Copy GNS3 configuration files
mkdir -p /home/vagrant/.config/GNS3/2.2
chown vagrant:vagrant -R /home/vagrant/.config/GNS3
cp /vagrant/gns3_gui.conf /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
cp /vagrant/gns3_gui.conf /home/vagrant/.config/GNS3/2.2/gns3_server.conf
chown vagrant:vagrant /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
chown vagrant:vagrant /home/vagrant/.config/GNS3/2.2/gns3_server.conf
chmod 664 /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
chmod 664 /home/vagrant/.config/GNS3/2.2/gns3_server.conf

# Reboot due to GNOME desktop install
# reboot