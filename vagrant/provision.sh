#!/usr/bin/env bash

# Install lightweight desktop environment (XFCE4) and display manager (LightDM)
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y xfce4 lightdm lightdm-gtk-greeter firefox virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
