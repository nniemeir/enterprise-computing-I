#!/bin/bash
NIC=enp0s3
NEW_GATEWAY=172.16.16.1
NEW_DNS=172.16.16.2
NEW_IP=172.16.16.3
NEW_HOSTNAME=conductor.universalnoodles.lan
REALM=UNIVERSALNOODLES.LAN 
SERVER_HOSTNAME=station.universalnoodles.lan
DOMAIN=universalnoodles.lan

# Disable DHCP
sudo nmcli connection modify "$NIC" ipv4.method manual

# Set Hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Set IP Address
sudo nmcli connection modify "$NIC" ipv4.addresses "$NEW_IP"

# Set DNS to Cloudflare
sudo nmcli connection modify "$NIC" ipv4.dns "1.1.1.1"

# Set Gateway
sudo nmcli connection modify "$NIC" ipv4.gateway "$NEW_GATEWAY"

# Restart networking services
sudo systemctl restart NetworkManager

# Add hostname to /etc/hosts
echo "$NEW_IP    $NEW_HOSTNAME" | sudo tee -a /etc/hosts

# Add IPA server to /etc/hosts
echo "$NEW_DNS    $SERVER_HOSTNAME" | sudo tee -a /etc/hosts

# Disable Cockpit
sudo systemctl disable cockpit.socket

# Install pip
sudo dnf install python3-pip -y

# Install FreeIPA-client
sudo dnf install freeipa-client -y

# Enable freeipa services in firewalld
sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --add-service=dns --add-service=ssh --permanent

# Reload firewalld
sudo firewall-cmd --reload

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

# Set DNS to FreeIPA Server
sudo nmcli connection modify "$NIC" ipv4.dns "$NEW_DNS"

# Restart networking services
sudo systemctl restart NetworkManager

# Enroll FreeIPA client
sudo ipa-client-install --domain="$DOMAIN" --hostname="$NEW_HOSTNAME" --mkhomedir --no-ntp --principal=admin --realm="$REALM" --server="$SERVER_HOSTNAME" --password="$IPA_ADMIN_PASS" --unattended

#Procure Kerberos Ticket
kinit aperkins

# Reboot 
sudo systemctl reboot
