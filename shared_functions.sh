#!/bin/bash

disable_web_ui() {
    sudo systemctl disable cockpit.socket
    if [ $? -ne 0 ]; then
        echo "Failed to disable Cockpit service."
        exit 1
    fi
}

install_pkg() {
    local package_name=$1
    sudo dnf install -y $package_name
    if [ $? -ne 0 ]; then
        echo "Failed to install $package_name."
        exit 1
    fi
}

take_input_and_confirm() {
    local description="$1"
    while true; do
        read -p "Enter the desired $description: " input
        read -p "Confirm the $description: " input2
        if [ "$input" == "$input2" ]; then
            break
        else
            echo "Second input does not match the first, please try again."
        fi
    done
    echo "$input"
}

verify_sourced_vars() {
    local sourced_variables=("CLOUDFLARE_IP", "DOMAIN", "REALM", "TRUSTED_HOSTS", "PFSENSE_IP", "FREEIPA_DNS", "FREEIPA_HOSTNAME", "FREEIPA_IP", "FREEIPA_NIC", "ENROLL_USER", "ANSIBLE_HOSTNAME", "ANSIBLE_IP", "ANSIBLE_NIC", "DEVSTATION_HOSTNAME", "DEVSTATION_IP")
    for variables in "${sourced_variables[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: $var is not defined in preferences.conf"
            exit 1
        fi
    done
}
