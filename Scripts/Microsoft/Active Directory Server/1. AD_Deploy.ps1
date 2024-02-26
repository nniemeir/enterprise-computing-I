# Set the device's IP and Gateway
New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress 173.16.16.2 `
    -PrefixLength 24 `
    -DefaultGateway 173.16.16.1

# Set DNS server to Cloudflare
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 1.1.1.1

# Set hostname
Rename-Computer -NewName "station" -Force -PassThru

# Apply network configuration changes
Restart-NetAdapter -Name "Ethernet"

# Install Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "Configuring AD DS, the system will reboot once this task is complete"
Install-ADDSForest -DomainName "universalnoodles.lan" -InstallDns 

# Add DNS entries
$DNSCSV = Import-Csv ".\Records\DNS_Records.csv"
foreach ($Entry in $DNSCSV) {
    $Entry_IP = $Entry.IP
    $Entry_Hostname = $Entry.Hostname

    # Make sure that the DNS Record doesn't already exist
    if (Resolve-DnsName -Name $Entry_Hostname -Server "station.universalnoodles.lan") {
        Write-Warning "DNS Record for $Entry_Hostname Already Exists"
    }
    else {
        Add-DnsServerResourceRecordA `
        -Name "$Entry_Hostname" `
        -ZoneName "universalnoodles.lan" `
        -AllowUpdateAny `
        -IPv4Address "$Entry_IP" `
        -TimeToLive 01:00:00 `
        -ZoneName "universalnoodles.lan"
    }
}

# Add a DNS forwarder
Add-DnsServerForwarder -IPAddress 1.1.1.1 -PassThru

# Create a group for devices that users can access, these will be added once they are enrolled
New-ADGroup -Name "DevelopmentWorkstations" -GroupScope Global -GroupCategory Security

Read-Host "Press Enter to exit"
