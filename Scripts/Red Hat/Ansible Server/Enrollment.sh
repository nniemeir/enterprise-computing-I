#!/bin/bash

main() {
	# Ensure configuration file is present
	source ../preferences.conf || {
		echo "Error: No configuration file found."
		exit 1
	}

	verify_sourced_vars

	source ../shared_functions.sh || {
		echo "Error: shared_functions.sh not found."
		exit 1
	}

	ipa_admin_pass=$(take_input_and_confirm "IPA admin password")

	configure_network_parameters

	disable_web_ui

	install_dependencies

	configure_firewall

	set_dns_to_ipa

	enroll_ipa_client

	reboot
}

configure_network_parameters() {
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
}

install_dependencies() {
	# Install pip
	install_pkg python3-pip -y

	# Install FreeIPA-client
	install_pkg freeipa-client -y
}

configure_firewall() {
	# Enable FreeIPA services in firewalld
	sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --add-service=dns --add-service=ssh --permanent

	# Reload firewalld
	sudo firewall-cmd --reload
}

set_dns_to_ipa() {
	# Set DNS to FreeIPA server
	sudo nmcli connection modify "$ANSIBLE_NIC" ipv4.dns "$FREEIPA_IP"

	# Restart networking services
	sudo systemctl restart NetworkManager
}

enroll_ipa_client() {
	# Enroll FreeIPA client
	sudo ipa-client-install \
		--domain="$DOMAIN" \
		--hostname="$ANSIBLE_HOSTNAME" \
		--mkhomedir \
		--no-ntp \
		--principal=admin \
		--realm="$REALM" \
		--server="$FREEIPA_HOSTNAME" \
		--password="$ipa_admin_pass" \
		--unattended

	#Procure Kerberos Ticket
	kinit "$ENROLL_USER"
}

main "$@"
