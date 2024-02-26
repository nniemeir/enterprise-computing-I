#!/bin/bash
NIC=enp0s3
NEW_GATEWAY=172.16.16.1
NEW_DNS=1.1.1.1
NEW_IP=172.16.16.2
NEW_HOSTNAME=station.universalnoodles.lan

# Disable DHCP
sudo nmcli connection modify "$NIC" ipv4.method manual

# Set Hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Set IP Address
sudo nmcli connection modify "$NIC" ipv4.addresses "$NEW_IP"

# Set DNS
sudo nmcli connection modify "$NIC" ipv4.dns "$NEW_DNS"

# Set Gateway
sudo nmcli connection modify "$NIC" ipv4.gateway "$NEW_GATEWAY"

# Add hostname to /etc/hosts
echo "$NEW_IP    $NEW_HOSTNAME" | sudo tee -a /etc/hosts

# Restart networking services
sudo systemctl restart NetworkManager

# Disable Cockpit 
sudo systemctl disable cockpit.socket

# Install GNOME 
sudo dnf groupinstall gnome -y

# Install pip
sudo dnf install python3-pip -y

# Install Ansible
python3 -m pip install --user ansible-core

# Install Ansible's POSIX collection
ansible-galaxy collection install ansible.posix

# Allow SSH through firewalld
sudo firewall-cmd --permanent --add-service=dns --permanent

# Install FreeIPA-client
sudo dnf install freeipa-server freeipa-server-dns -y

# Enable FreeIPA services in firewalld
sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --permanent

# Reload firewalld
sudo firewall-cmd --reload

# Enabling graphical environment and rebooting
systemctl set-default graphical.target
reboot
