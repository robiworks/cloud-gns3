#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Add all required PPAs
add-apt-repository ppa:gns3/ppa -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install XFCE4
apt-get update
apt-get upgrade -y
apt-get install -y xfce4 lightdm firefox

# Change display manager to LightDM
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate

# Remove GDM3 completely
# https://ubuntu-mate.community/t/how-to-switch-back-to-lightdm-from-gdm3/19015/2
apt-get purge -y gdm3 ubuntu-session xwayland
apt-get autoremove -y

# Fix LightDM config
# https://cialu.net/how-to-solve-failed-to-start-session-with-lightdm-and-xfce/
rm /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
cat > /usr/share/lightdm/lightdm.conf.d/50-xfce-greeter.conf << EOF
[SeatDefaults]
greeter-session=unity-greeter
user-session=xfce
EOF

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

# Copy GNS3 configuration files
mkdir -p /home/vagrant/.config/GNS3/2.2
chown vagrant:vagrant -R /home/vagrant/.config/GNS3
cp /vagrant/gns3_gui.conf /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
cp /vagrant/gns3_gui.conf /home/vagrant/.config/GNS3/2.2/gns3_server.conf
chown vagrant:vagrant /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
chown vagrant:vagrant /home/vagrant/.config/GNS3/2.2/gns3_server.conf
chmod 664 /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
chmod 664 /home/vagrant/.config/GNS3/2.2/gns3_server.conf
