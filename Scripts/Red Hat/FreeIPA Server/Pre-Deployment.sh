#!/bin/bash

# Ensure configuration file is present
source ../preferences.conf || {
	echo "Error: No configuration file found."
	exit 1
}

# Disable DHCP
sudo nmcli connection modify "$FREEIPA_NIC" ipv4.method manual

# Set Hostname
sudo hostnamectl set-hostname "$FREEIPA_HOSTNAME"

# Set IP Address
sudo nmcli connection modify "$FREEIPA_NIC" ipv4.addresses "$FREEIPA_NIC"

# Set DNS
sudo nmcli connection modify "$FREEIPA_NIC" ipv4.dns "$FREEIPA_DNS"

# Set Gateway
sudo nmcli connection modify "$FREEIPA_NIC" ipv4.gateway "$PFSENSE_IP"

# Add hostname to /etc/hosts
echo "$FREEIPA_IP    $FREEIPA_HOSTNAME" | sudo tee -a /etc/hosts

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
