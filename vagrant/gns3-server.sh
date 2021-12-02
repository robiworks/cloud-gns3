#!/usr/bin/env bash

# Install GNS3 server
export DEBIAN_FRONTEND=noninteractive
add-apt-repository ppa:gns3/ppa -y
apt-get update
apt-get install gns3-server -y

# Add vagrant user to groups ubridge, libvirt, kvm
usermod -aG ubridge vagrant
usermod -aG libvirt vagrant
usermod -aG kvm vagrant
usermod -aG wireshark vagrant

# Create a GNS3 server service and run it at boot
cat > /etc/systemd/system/gns3.service << EOF
[Unit]
Description=GNS3 Server

[Service]
ExecStart=/usr/share/gns3/gns3-server/bin/gns3server

[Install]
WantedBy=multi-user.target
EOF
chmod +x /etc/systemd/system/gns3.service
systemctl enable gns3
systemctl start gns3