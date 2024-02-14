#!/bin/bash
NEW_DNS=172.16.16.2
NEW_GATEWAY=172.16.16.1
NEW_IP=172.16.16.5
NEW_HOSTNAME=parrot.universalnoodles.lan

# Set IP Address
sudo nmcli connection modify "Wired connection 1" ipv4.addresses "$NEW_IP"

# Disable DHCP
sudo nmcli connection modify "Wired connection 1" ipv4.method manual

# Set Hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Add hostname to /etc/hosts
echo "$NEW_IP    $NEW_HOSTNAME" | sudo tee -a /etc/hosts

# Set DNS to Cloudflare
sudo nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1"

# Set Gateway
sudo nmcli connection modify "Wired connection 1" ipv4.gateway "$NEW_GATEWAY"

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

# Set DNS to FreeIPA Server
sudo nmcli connection modify "Wired connection 1" ipv4.dns "$NEW_DNS"