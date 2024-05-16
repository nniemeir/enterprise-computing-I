#!/bin/bash

# Ensure configuration file is present
source ../preferences.conf || {
	echo "Error: No configuration file found."
	exit 1
}

# Set IP Address
sudo nmcli connection modify "Wired connection 1" ipv4.addresses "$PARROT_IP"

# Disable DHCP
sudo nmcli connection modify "Wired connection 1" ipv4.method manual

# Set hostname
sudo hostnamectl set-hostname "$PARROT_HOSTNAME"

# Add hostname to /etc/hosts
echo "$PARROT_IP    $PARROT_HOSTNAME" | sudo tee -a /etc/hosts

# Set DNS to Cloudflare
sudo nmcli connection modify "Wired connection 1" ipv4.dns "$CLOUDFLARE_IP"

# Set gateway
sudo nmcli connection modify "Wired connection 1" ipv4.gateway "$PFSENSE_IP"

# Restart networking services
sudo systemctl restart NetworkManager

# Download Nessus .deb file
curl --request GET \
  --url 'https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.6.3-debian10_amd64.deb' \
  --output 'nessus.deb'

# Install Nessus
sudo dpkg -i nessus.deb

# Start Nessus daemon
sudo systemctl start nessusd.service

# Restart networking services
sudo systemctl restart NetworkManager

# The user would change their DNS server to the FreeIPA server after registering Nessus
read -p "Press Enter to continue after configuring Nessus"

# Set DNS to FreeIPA server
sudo nmcli connection modify "Wired connection 1" ipv4.dns "$FREEIPA_IP"
