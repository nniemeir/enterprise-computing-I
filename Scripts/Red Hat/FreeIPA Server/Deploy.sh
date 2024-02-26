#!/bin/bash
NIC=enp0s3
NEW_IP=172.16.16.2
NEW_DNS=127.0.0.1
NEW_HOSTNAME=station.universalnoodles.lan
REALM=UNIVERSALNOODLES.LAN 
DOMAIN=universalnoodles.lan
TRUSTED_HOSTS="127.0.0.1;172.16.16.1;172.16.16.3;172.16.16.4"

# Take user input for IPA Admin password and have them confirm their choice
while true; do
	read -p "Enter the desired IPA Admin password: " IPA_ADMIN_PASS
	read -p "Confirm the IPA Admin password: " IPA_ADMIN_PASS_2
	if [ "$IPA_ADMIN_PASS" == "$IPA_ADMIN_PASS_2" ]; then
		break
	else
		echo "Passwords do not match"
	fi
done

# Take user input for Directory Manager password and have them confirm their choice
while true; do

	read -p "Enter the desired Directory Manager password: " DM_PASS
	read -p "Confirm the Directory Manager password: " DM_PASS_2
	if [ "$DM_PASS" == "$DM_PASS_2" ]; then
		break
	else
		echo "Passwords do not match"
	fi
done

# Set DNS to self
sudo nmcli connection modify "$NIC" ipv4.dns "$NEW_DNS"

# Restart networking services
sudo systemctl restart NetworkManager

# Deploy FreeIPA
sudo ipa-server-install --setup-dns --forwarder=1.1.1.1 --auto-reverse --realm="$REALM" --domain="$DOMAIN" --hostname="$NEW_HOSTNAME" --ip-address="$NEW_IP" --ds-password="$DM_PASS" --admin-password="$IPA_ADMIN_PASS" --mkhomedir --no-ntp --unattended

# Obtain a TGT
kinit admin

# Set default shell
ipa config-mod --defaultshell=/bin/bash

# Add DNS records
while IFS="," read -r recIP recHostname
do
    ipa dnsrecord-add $DOMAIN "$recHostname" --a-rec="$recIP"
done < "Records/DNS_Records.csv"

# Create user groups
ipa group-add desktop_admins
ipa group-add developers

# Create host groups, host will be added manually to these once we have some enrolled
ipa hostgroup-add developer_workstations
ipa hostgroup-add non-FreeIPA_servers 

# Create users and add them to appropriate groups
while IFS="," read -r username first last title
do
    # Remove trailing whitespace characters
    title=${title%$'\r'}
    title=${title%%$'\n'}

    # Add user based on values in CSV file
    ipa user-add "$username" --cn="$first $last" --first="$first" --last="$last" --title="$title"
    
    # Generate a secure temporary password for the user
    echo "$username" > Temporary/"$first $last".txt
    tempPass=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 16)
    ipa user-mod "$username" --setattr userpassword="$tempPass"
    echo "$tempPass" >> Temporary/"$first $last".txt
    
    # Require user to change password on first login
    ipa user-mod "$username" --setattr krbpasswordexpiration="2023-11-18 20:00:00Z"
    
    # Add user to desktop_admins group
    ipa group-add-member desktop_admins --users="$username"

done < "Records/Users_Desktop_Admins.csv"

while IFS="," read -r username first last title
do
    # Remove trailing whitespace characters
    title=${title%$'\r'}
    title=${title%%$'\n'}

    # Add user based on values in CSV file
    ipa user-add "$username" --cn="$first $last" --first="$first" --last="$last" --title="$title"
    
    # Generate a secure temporary password for the user
    echo "$username" > Temporary/"$first $last".txt
    tempPass=$(tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 16)
    ipa user-mod "$username" --setattr userpassword="$tempPass"
    echo "$tempPass" >> Temporary/"$first $last".txt
    
    # Require user to change password on first login
    ipa user-mod "$username" --setattr krbpasswordexpiration="2023-11-18 20:00:00Z"
    
    # Add user to developers group
    ipa group-add-member developers --users="$username"

done < "Records/Users_Developers.csv"

# Create sudo rule
ipa sudorule-add desktop_admins_sudo --cmdcat=all

# Allow desktop admins to use sudo on ansible server and developer workstations
ipa sudorule-add-host desktop_admins_sudo --hosts=conductor --hostgroup=developer_workstations

# Apply rule to desktop admins
ipa sudorule-add-user desktop_admins_sudo --groups=desktop_admins

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

# Create global password policy
ipa pwpolicy-mod --maxlife=42 --minlife=48 --history=5 --minclasses=4 --minlength=12 --maxfail=3 --failinterval=1800 --lockouttime=540000 --gracelimit=3

# Only allow DNS queries from trusted hosts
ipa dnszone-mod "$DOMAIN" --allow-query="$TRUSTED_HOSTS"

# Reboot 
sudo systemctl reboot
