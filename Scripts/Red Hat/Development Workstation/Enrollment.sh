#!/bin/bash
NEW_DNS=172.16.16.2
NEW_IP=172.16.16.4
NEW_HOSTNAME=passenger01.universalnoodles.lan
REALM=UNIVERSALNOODLES.LAN 
SERVER_HOSTNAME=station.universalnoodles.lan
DOMAIN=universalnoodles.lan

# Disable DHCP
sudo nmcli connection modify "Wired connection 1" ipv4.method manual

# Set IP Address
sudo nmcli connection modify "Wired connection 1" ipv4.addresses "$NEW_IP"

# Set Hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Add hostname to /etc/hosts
echo "$NEW_IP    $NEW_HOSTNAME" | sudo tee -a /etc/hosts

# Add IPA server to /etc/hosts
echo "$NEW_DNS    $SERVER_HOSTNAME" | sudo tee -a /etc/hosts

# Set DNS to Cloudflare
sudo nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1"

# Set Gateway
sudo nmcli connection modify "Wired connection 1" ipv4.gateway "$NEW_GATEWAY"

# Restart networking services
sudo systemctl restart NetworkManager

# Install pip
sudo dnf install python3-pip -y

# Install OpenSSH Server
sudo dnf install openssh-server -y

# Enable sshd service
sudo systemctl enable sshd.service

# Install FreeIPA-client
sudo dnf install freeipa-client

# Enable freeipa services in firewalld
sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --add-service=dns --add-service=ssh --permanent

# Reload firewalld
sudo firewall-cmd --reload\

# Take user input for IPA Admin password and have them confirm their choice
while true; do
	read -p "Enter the password of a user authorized to enroll devices: " IPA_ADMIN_PASS
	read -p "Enter the password again: " IPA_ADMIN_PASS_2
	if [ "$IPA_ADMIN_PASS" == "$IPA_ADMIN_PASS_2" ]; then
		break
	else
		echo "Passwords do not match"
	fi
done

# Set DNS
sudo nmcli connection modify "Wired connection 1" ipv4.dns "$NEW_DNS"

# Restart networking services
sudo systemctl restart NetworkManager

# Enroll device as FreeIPA client
sudo ipa-client-install --domain="$DOMAIN" --hostname="$NEW_HOSTNAME" --mkhomedir --no-ntp --principal=admin --realm="$REALM" --server="$SERVER_HOSTNAME" --password="$IPA_ADMIN_PASS" --unattended

# Procure Kerberos Ticket
kinit aperkins

# Reboot 
sudo systemctl reboot