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

    # Take user input for IPA Admin password and have them confirm their choice
    ipa_admin_pass=$(take_input_and_confirm "IPA admin password")

    dm_pass=$(take_input_and_confirm "Directory Manager password")

    configure_network_parameters

    deploy_freeipa

    # Set default shell
    ipa config-mod --defaultshell=/bin/bash

    configure_dns

    create_groups

    add_users_from_csvs

    set_sudo_rule

    create_hbac_rules

    set_password_policy

    reboot
}

configure_network_parameters() {
    # Set DNS to self
    sudo nmcli connection modify "$FREEIPA_NIC" ipv4.dns "$NEW_DNS"

    # Restart networking services
    sudo systemctl restart NetworkManager
}

deploy_freeipa() {
    # Deploy FreeIPA
    sudo ipa-server-install --setup-dns \
        --forwarder="$CLOUDFLARE_IP" \
        --auto-reverse \
        --realm="$REALM" \
        --domain="$DOMAIN" \
        --hostname="$FREEIPA_HOSTNAME" \
        --ip-address="$FREEIPA_IP" \
        --ds-password="$dm_pass" \
        --admin-password="$ipa_admin_pass" \
        --mkhomedir \
        --no-ntp \
        --unattended

    # Obtain a TGT
    kinit admin
}

configure_dns() {
    # Add DNS records
    while IFS="," read -r rec_ip rec_hostname; do
        ipa dnsrecord-add $DOMAIN "$rec_hostname" --a-rec="$rec_ip"
    done <"Records/DNS_Records.csv"

    # Only allow DNS queries from trusted hosts
    ipa dnszone-mod "$DOMAIN" --allow-query="$TRUSTED_HOSTS"
}

create_groups() {
    # Create user groups
    ipa group-add desktop_admins
    ipa group-add developers

    # Create host groups, host will be added manually to these once we have some enrolled
    ipa hostgroup-add developer_workstations
    ipa hostgroup-add non-FreeIPA_servers
}

add_users_from_csvs() {
    # Create users and add them to appropriate groups
    while IFS=";" read -r first last username title; do
        # Remove trailing whitespace characters
        title=${title%$'\r'}
        title=${title%%$'\n'}

        # Add user based on values in CSV file
        ipa user-add "$username" --cn="$first $last" --first="$first" --last="$last" --title="$title"

        # Generate a secure temporary password for the user
        echo "$username" >Temporary/"$first $last".txt
        temp_pass=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 16)
        ipa user-mod "$username" --setattr userpassword="$temp_pass"
        echo "$temp_pass" >>Temporary/"$first $last".txt

        # Require user to change password on first login
        ipa user-mod "$username" --setattr krbpasswordexpiration="2023-11-18 20:00:00Z"

        # Add user to desktop_admins group
        ipa group-add-member desktop_admins --users="$username"

    done <"Records/Users_Desktop_Admins.csv"

    while IFS=";" read -r username first last title; do
        # Remove trailing whitespace characters
        title=${title%$'\r'}
        title=${title%%$'\n'}

        # Add user based on values in CSV file
        ipa user-add "$username" --cn="$first $last" --first="$first" --last="$last" --title="$title"

        # Generate a secure temporary password for the user
        echo "$username" >Temporary/"$first $last".txt
        temp_pass=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 16)
        ipa user-mod "$username" --setattr userpassword="$temp_pass"
        echo "$temp_pass" >>Temporary/"$first $last".txt

        # Require user to change password on first login
        ipa user-mod "$username" --setattr krbpasswordexpiration="2025-2-1 20:00:00Z"

        # Add user to developers group
        ipa group-add-member developers --users="$username"

    done <"Records/Users_Developers.csv"
}

set_sudo_rule() {
    # Create sudo rule
    ipa sudorule-add desktop_admins_sudo --cmdcat=all

    # Allow desktop admins to use sudo on ansible server and developer workstations
    ipa sudorule-add-host desktop_admins_sudo --hosts=conductor --hostgroup=developer_workstations

    # Apply rule to desktop admins
    ipa sudorule-add-user desktop_admins_sudo --groups=desktop_admins
}

create_hbac_rules() {
    # Disable Allow All HBAC rule
    ipa hbacrule-disable allow_all

    # Create HBAC rule for desktop admins
    ipa hbacrule-add desktop_admins_access

    # Apply rule to desktop admins
    ipa hbacrule-add-user desktop_admins_access --groups=desktop_admins

    # Include developer workstations in rule
    ipa hbacrule-add-host desktop_admins_access --hostgroups="developer_workstations"

    # Include non-FreeIPA servers in rule
    ipa hbacrule-add-host desktop_admins_access --hostgroups="non-freeipa_servers"

    # Apply rule to all services
    ipa hbacrule-mod desktop_admins_access --servicecat=all

    # Create HBAC rule for developers
    ipa hbacrule-add developers_access

    # Apply rule to developers
    ipa hbacrule-add-user developers_access --group=developers

    # Include developer workstations in rule
    ipa hbacrule-add-host developers_access --hostgroups="developer_workstations"

    # Apply to all services
    ipa hbacrule-mod developers_access --servicecat=all
}

set_password_policy() {
    ipa pwpolicy-mod \
        --maxlife=42 \
        --minlife=48 \
        --history=5 \
        --minclasses=4 \
        --minlength=12 \
        --maxfail=3 \
        --failinterval=1800 \
        --lockouttime=540000 \
        --gracelimit=3
}

main "$@"
