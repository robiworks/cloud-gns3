#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y xserver-xorg-video-dummy x11vnc
apt-get install -y lightdm

echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate

cat > /etc/X11/xorg.conf << EOF
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    Modeline "1920x1080_60.00" 172.80 1920 2040 2248 2576 1080 1081 1084 1118 -HSync +Vsync
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080_60.00"
    EndSubSection
EndSection
EOF

x11vnc -storepasswd msi-gns3 /etc/x11vnc.pass
cat > /etc/systemd/system/x11vnc.service << EOF
[Unit]
Description="x11vnc"
Requires=display-manager.service
After=display-manager.service

[Service]
ExecStart=/usr/bin/x11vnc -geometry 1920x1080 -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth /etc/x11vnc.pass
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start x11vnc
systemctl enable x11vnc

# https://askubuntu.com/questions/1033274/ubuntu-18-04-connect-to-login-screen-over-vnc
# Might be better to just enable GDM3 autologin and start the VNC server after autologin, don't use LightDM and tell the user that they should not log out.

reboot