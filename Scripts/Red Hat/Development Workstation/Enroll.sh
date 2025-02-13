#!/bin/bash

main() {
	# Ensure configuration file is present
	source ../preferences.conf || {
		echo "Error: No configuration file found."
		exit 1
	}

	source ../shared_functions.sh || {
		echo "Error: shared_functions.sh not found."
		exit 1
	}

	ipa_admin_pass=$(take_input_and_confirm "IPA admin password")

	configure_network_parameters

	install_dependencies

	configure_firewall

	set_dns_to_ipa

	enroll_ipa_client

	reboot
}

configure_network_parameters() {
	# Disable DHCP
	sudo nmcli connection modify "Wired connection 1" ipv4.method manual

	# Set IP Address
	sudo nmcli connection modify "Wired connection 1" ipv4.addresses "$DEVSTATION_IP"

	# Set hostname
	sudo hostnamectl set-hostname "$DEVSTATION_HOSTNAME"

	# Add hostname to /etc/hosts
	echo "$DEVSTATION_IP    $DEVSTATION_HOSTNAME" | sudo tee -a /etc/hosts

	# Add IPA server to /etc/hosts
	echo "$FREEIPA_IP    $FREEIPA_HOSTNAME" | sudo tee -a /etc/hosts

	# Set DNS to Cloudflare
	sudo nmcli connection modify "Wired connection 1" ipv4.dns "$CLOUDFLARE_IP"

	# Set gateway
	sudo nmcli connection modify "Wired connection 1" ipv4.gateway "$PFSENSE_IP"

	# Restart networking services
	sudo systemctl restart NetworkManager
}

install_dependencies() {
	# Install pip
	sudo dnf install python3-pip -y

	# Install OpenSSH Server
	sudo dnf install openssh-server -y

	# Enable SSHD service
	sudo systemctl enable sshd.service

	# Install FreeIPA-client
	sudo dnf install freeipa-client
}

configure_firewall() {
	# Enable FreeIPA services in firewalld
	sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --add-service=dns --add-service=ssh --permanent

	# Reload firewalld
	sudo firewall-cmd --reload
}

set_dns_to_ipa() {
	# Set DNS
	sudo nmcli connection modify "Wired connection 1" ipv4.dns "$FREEIPA_IP"

	# Restart networking services
	sudo systemctl restart NetworkManager
}

enroll_ipa_client() {
	# Enroll device as FreeIPA client
	sudo ipa-client-install \
		--domain="$DOMAIN" \
		--hostname="$DEVSTATION_HOSTNAME" \
		--mkhomedir \
		--no-ntp \
		--principal=admin \
		--realm="$REALM" \
		--server="$FREEIPA_HOSTNAME" \
		--password="$ipa_admin_pass" \
		--unattended

	# Procure Kerberos ticket
	kinit "$ENROLL_USER"
}

main "$@"
