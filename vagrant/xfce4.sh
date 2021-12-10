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
# https://askubuntu.com/a/1120828
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
usermod -aG wireshark vagrant
usermod -aG docker vagrant

# Make GNS3 config directory if it doesn't exist
mkdir -p /home/vagrant/.config/GNS3/2.2
chown vagrant:vagrant -R /home/vagrant/.config/GNS3

# Create GNS3 server config
cat > /home/vagrant/.config/GNS3/2.2/gns3_server.conf << EOF
[Server]
path = /usr/bin/gns3server
ubridge_path = /usr/bin/ubridge
host = localhost
port = 3080
images_path = /home/vagrant/GNS3/images
projects_path = /home/vagrant/GNS3/projects
appliances_path = /home/vagrant/GNS3/appliances
additional_images_paths = 
symbols_path = /home/vagrant/GNS3/symbols
configs_path = /home/vagrant/GNS3/configs
report_errors = True
auto_start = True
allow_console_from_anywhere = False
auth = True
user = admin
password = gjuZWoOFZKLZ5EwQSCBggkXfjGDvjuL4a47FEGm2Wtc4HnkmEZN11IgaBjxVSQ5f
protocol = http
console_start_port_range = 5000
console_end_port_range = 10000
udp_start_port_range = 10000
udp_end_port_range = 20000
EOF

# Create GNS3 GUI config
cat > /home/vagrant/.config/GNS3/2.2/gns3_gui.conf << EOF
{
    "Builtin": {
        "default_nat_interface": "virbr0"
    },
    "Docker": {
        "containers": []
    },
    "Dynamips": {
        "allocate_aux_console_ports": false,
        "dynamips_path": "",
        "ghost_ios_support": true,
        "mmap_support": true,
        "sparse_memory_support": true
    },
    "GraphicsView": {
        "default_label_color": "#000000",
        "default_label_font": "TypeWriter,10,-1,5,75,0,0,0,0,0",
        "default_note_color": "#000000",
        "default_note_font": "TypeWriter,10,-1,5,75,0,0,0,0,0",
        "draw_link_status_points": true,
        "draw_rectangle_selected_item": false,
        "drawing_grid_size": 25,
        "grid_size": 75,
        "limit_size_node_symbols": true,
        "scene_height": 1000,
        "scene_width": 2000,
        "show_grid": false,
        "show_grid_on_new_project": false,
        "show_interface_labels": false,
        "show_interface_labels_on_new_project": false,
        "show_layers": false,
        "snap_to_grid": false,
        "snap_to_grid_on_new_project": false,
        "zoom": null
    },
    "IOU": {
        "iourc_content": "",
        "license_check": true
    },
    "MainWindow": {
        "check_for_update": true,
        "debug_level": 0,
        "delay_console_all": 500,
        "direct_file_upload": false,
        "experimental_features": false,
        "geometry": "AdnQywADAAAAAAAAAAAAGwAAB38AAAQ3AAAAAAAAADMAAAd/AAAENwAAAAACAAAAB4AAAAAAAAAAMwAAB38AAAQ3",
        "hdpi": false,
        "hide_getting_started_dialog": false,
        "hide_new_template_button": false,
        "hide_setup_wizard": true,
        "last_check_for_update": 1639122153,
        "multi_profiles": false,
        "overlay_notifications": true,
        "recent_files": [],
        "recent_projects": [],
        "send_stats": true,
        "spice_console_command": "remote-viewer spice://%h:%p",
        "state": "AAAA/wAAAAD9AAAAAwAAAAAAAAAAAAAAAPwCAAAAAfsAAAAiAHUAaQBOAG8AZABlAHMARABvAGMAawBXAGkAZABnAGUAdAAAAAAA/////wAAAIoA////AAAAAQAAAQAAAALR/AIAAAAC+wAAADYAdQBpAFQAbwBwAG8AbABvAGcAeQBTAHUAbQBtAGEAcgB5AEQAbwBjAGsAVwBpAGQAZwBlAHQBAAAAPgAAAWYAAABZAP////sAAAA0AHUAaQBDAG8AbQBwAHUAdABlAFMAdQBtAG0AYQByAHkARABvAGMAawBXAGkAZABnAGUAdAEAAAGqAAABZQAAAFkA////AAAAAwAAB0QAAADT/AEAAAAB+wAAACYAdQBpAEMAbwBuAHMAbwBsAGUARABvAGMAawBXAGkAZABnAGUAdAEAAAA8AAAHRAAAAEYAB///AAAGPgAAAtEAAAAEAAAABAAAAAgAAAAI/AAAAAIAAAAAAAAAAQAAACIAdQBpAEIAcgBvAHcAcwBlAHIAcwBUAG8AbwBsAEIAYQByAwAAAAD/////AAAAAAAAAAAAAAACAAAAAwAAACAAdQBpAEcAZQBuAGUAcgBhAGwAVABvAG8AbABCAGEAcgEAAAAA/////wAAAAAAAAAAAAAAIAB1AGkAQwBvAG4AdAByAG8AbABUAG8AbwBsAEIAYQByAQAAAF7/////AAAAAAAAAAAAAAAmAHUAaQBBAG4AbgBvAHQAYQB0AGkAbwBuAFQAbwBvAGwAQgBhAHIBAAABkP////8AAAAAAAAAAA==",
        "stats_visitor_id": "26f9e634-ff09-4453-ace1-27744f93d857",
        "style": "Charcoal",
        "symbol_theme": "Classic",
        "telnet_console_command": "gnome-terminal -t \"%d\" -e \"telnet %h %p\"",
        "vnc_console_command": "vncviewer %h:%p"
    },
    "NodesView": {
        "nodes_view_filter": 0
    },
    "PacketCapture": {
        "command_auto_start": true,
        "packet_capture_analyzer_command": "",
        "packet_capture_reader_command": "tail -f -c +0b %c | wireshark -o \"gui.window_title:%d\" -k -i -"
    },
    "Qemu": {
        "enable_hardware_acceleration": true,
        "require_hardware_acceleration": true
    },
    "VMware": {
        "block_host_traffic": false,
        "host_type": "ws",
        "vmnet_end_range": 100,
        "vmnet_start_range": 2,
        "vmrun_path": ""
    },
    "VPCS": {
        "vpcs_path": ""
    },
    "VirtualBox": {
        "vboxmanage_path": ""
    },
    "type": "settings",
    "version": "2.2.27"
}
EOF

# Change ownership and permissions of config files
chown vagrant:vagrant /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
chown vagrant:vagrant /home/vagrant/.config/GNS3/2.2/gns3_server.conf
chmod 664 /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
chmod 664 /home/vagrant/.config/GNS3/2.2/gns3_server.conf
