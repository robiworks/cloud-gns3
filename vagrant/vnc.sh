#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y install tigervnc-standalone-server

myuser="vagrant"
mypswd="msi-gns3"

mkdir /home/$myuser/.vnc
echo $mypswd | vncpasswd -f > /home/$myuser/.vnc/passwd
chown -R $myuser:$myuser /home/$myuser/.vnc
chmod 0600 /home/$myuser/.vnc/passwd

cat > /home/$myuser/.vnc/xstartup << EOF
#!/bin/sh
# Start Gnome 3 Desktop 
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
dbus-launch --exit-with-session gnome-session &
EOF
chown $myuser:$myuser /home/$myuser/.vnc/xstartup
chmod 0600 /home/$myuser/.vnc/xstartup

cat > /etc/systemd/system/vncserver@.service << EOF
[Unit]
Description=TigerVNC Server
After=syslog.target network.target

[Service]
Type=forking
User=vagrant

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || :
ExecStart=/usr/bin/vncserver -geometry 1600x900 -depth 24 -localhost no :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

systemctl enable vncserver@1
systemctl start vncserver@1

reboot
