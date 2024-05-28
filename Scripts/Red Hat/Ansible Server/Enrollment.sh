#!/bin/bash

# Ensure configuration file is present
source ../preferences.conf || {
	echo "Error: No configuration file found."
	exit 1
}

# Disable DHCP
sudo nmcli connection modify "$ANSIBLE_NIC" ipv4.method manual

# Set hostname
sudo hostnamectl set-hostname "$ANSIBLE_HOSTNAME"

# Set IP address
sudo nmcli connection modify "$ANSIBLE_NIC" ipv4.addresses "$ANSIBLE_IP"

# Set DNS to Cloudflare
sudo nmcli connection modify "$ANSIBLE_NIC" ipv4.dns "$CLOUDFLARE_IP"

# Set gateway
sudo nmcli connection modify "$ANSIBLE_NIC" ipv4.gateway "$PFSENSE_IP"

# Restart networking services
sudo systemctl restart NetworkManager

# Add hostname to /etc/hosts
echo "$ANSIBLE_IP    $ANSIBLE_HOSTNAME" | sudo tee -a /etc/hosts

# Add IPA server to /etc/hosts
echo "$FREEIPA_IP    $FREEIPA_HOSTNAME" | sudo tee -a /etc/hosts

# Disable Cockpit
sudo systemctl disable cockpit.socket

# Install pip
sudo dnf install python3-pip -y

# Install FreeIPA-client
sudo dnf install freeipa-client -y

# Enable FreeIPA services in firewalld
sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --add-service=dns --add-service=ssh --permanent

# Reload firewalld
sudo firewall-cmd --reload

# Take user input for IPA Admin password and have them confirm their choice
while true; do
	read -p "Enter the password of a user authorized to enroll devices: " ipa_admin_pass
	read -p "Enter the password again: " ipa_admin_pass_2
	if [ "$ipa_admin_pass" == "$ipa_admin_pass_2" ]; then
		break
	else
		echo "Passwords do not match"
	fi
done

# Set DNS to FreeIPA server
sudo nmcli connection modify "$ANSIBLE_NIC" ipv4.dns "$FREEIPA_IP"

# Restart networking services
sudo systemctl restart NetworkManager

# Enroll FreeIPA client
sudo ipa-client-install --domain="$DOMAIN" --hostname="$ANSIBLE_HOSTNAME" --mkhomedir --no-ntp --principal=admin --realm="$REALM" --server="$FREEIPA_HOSTNAME" --password="$ipa_admin_pass" --unattended

#Procure Kerberos Ticket
kinit "$ENROLL_USER"

# Reboot 
sudo systemctl reboot
