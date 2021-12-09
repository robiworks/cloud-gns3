#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y install tigervnc-standalone-server

myuser="vagrant"
mypswd="msi-gns3"

mkdir /home/$myuser/.vnc
echo $mypswd | vncpasswd -f > /home/$myuser/.vnc/passwd
chown -R $myuser:$myuser /home/$myuser/.vnc
chmod 600 /home/$myuser/.vnc/passwd

cat > /home/$myuser/.vnc/xstartup << EOF
#!/bin/sh
# Start Gnome 3 Desktop 
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
dbus-launch --exit-with-session gnome-session &
EOF
chown $myuser:$myuser /home/$myuser/.vnc/xstartup
chmod 755 /home/$myuser/.vnc/xstartup

cat >> /home/vagrant/.profile << EOF
vncserver :1 -geometry 1920x1080 -depth 24 -localhost
EOF

reboot
