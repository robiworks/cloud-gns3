#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Install X11VNC and Xorg dummy driver
apt-get update
apt-get install -y x11vnc xserver-xorg-video-dummy

# Set up X11VNC password
x11vnc -storepasswd msi-gns3 /etc/x11vnc.pass

# Configure X11VNC https://askubuntu.com/a/1044081
cat > /etc/systemd/system/x11vnc.service << EOF
# Description: Custom Service Unit file
# File: /etc/systemd/system/x11vnc.service
[Unit]
Description="x11vnc"
Requires=display-manager.service
After=display-manager.service

[Service]
ExecStart=/usr/bin/x11vnc -geometry 1920x1080 -loop -nopw -xkb -repeat -noxrecord -noxfixes -noxdamage -forever -rfbport 5900 -display :0 -auth guess
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

# Configure Xorg dummy display
cat > /etc/X11/xorg.conf << EOF
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync 5.0 - 1000.0
    VertRefresh 5.0 - 200.0
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

systemctl daemon-reload
systemctl enable x11vnc.service

chown vagrant:vagrant -R /home/vagrant

reboot
