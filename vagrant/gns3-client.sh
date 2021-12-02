#!/usr/bin/env bash

# Add GNS3 PPA and update & upgrade package index
add-apt-repository ppa:gns3/ppa -y
apt-get update
apt-get upgrade -y

# Install minimal desktop
apt-get install xfce4 xorg lightdm firefox -y
rm /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
cat > /usr/share/lightdm/lightdm.conf.d/50-xfce-greeter.conf << EOF
[SeatDefaults]
greeter-session=unity-greeter
user-session=xfce
allow-guest=false
autologin-user=vagrant
autologin-user-timeout=0
EOF

# Install GNS3 GUI
#export DEBIAN_FRONTEND=noninteractive

# Reboot after installing
reboot