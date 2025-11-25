#!/bin/bash

main() {
	source ../preferences.conf || {
		echo "Error: No configuration file found."
		exit 1
	}

	verify_sourced_vars

	source ../shared_functions.sh || {
		echo "Error: shared_functions.sh not found."
		exit 1
	}

	set_network_parameters
	disable_unneeded_services
	install_dependencies
	configure_firewalld

	# Enabling graphical environment and rebooting
	systemctl set-default graphical.target

	reboot
}

set_network_parameters() {
	# Disable DHCP
	sudo nmcli connection modify "$FREEIPA_NIC" ipv4.method manual

	# Set Hostname
	sudo hostnamectl set-hostname "$FREEIPA_HOSTNAME"

	# Set IP Address
	sudo nmcli connection modify "$FREEIPA_NIC" ipv4.addresses "$FREEIPA_IP"

	# Set DNS
	sudo nmcli connection modify "$FREEIPA_NIC" ipv4.dns "$FREEIPA_DNS"

	# Set Gateway
	sudo nmcli connection modify "$FREEIPA_NIC" ipv4.gateway "$PFSENSE_IP"

	# Add hostname to /etc/hosts
	echo "$FREEIPA_IP    $FREEIPA_HOSTNAME" | sudo tee -a /etc/hosts

	# Restart networking services
	sudo systemctl restart NetworkManager
}

install_dependencies() {
	# Install GNOME
	sudo dnf groupinstall gnome -y

	# Install Chromium to allow web UI access
	install_pkg chromium

	# Install pip
	install_pkg python3-pip -y

	# Install Ansible
	python3 -m pip install --user ansible-core

	# Install Ansible's POSIX collection
	ansible-galaxy collection install ansible.posix

	# Install FreeIPA-client
	install_pkg freeipa-server freeipa-server-dns -y
}

configure_firewalld() {
	# Allow SSH through firewalld
	sudo firewall-cmd --permanent --add-service=dns --permanent

	# Enable FreeIPA services in firewalld
	sudo firewall-cmd --add-service=freeipa-ldap --add-service=freeipa-ldaps --permanent

	# Reload firewalld
	sudo firewall-cmd --reload
}

main "$@"
