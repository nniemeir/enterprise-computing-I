
. .\..\preferences.ps1

# Set the device's IP and Gateway
New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress $ServerIP `
    -PrefixLength 24 `
    -DefaultGateway $PfSenseIP

# Set DNS server to Cloudflare
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $CloudflareIP

# Set hostname
Rename-Computer -NewName "$ServerHostname" -Force -PassThru

# Apply network configuration changes
Restart-NetAdapter -Name "Ethernet"

# Install Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "Configuring AD DS, the system will reboot once this task is complete"
Install-ADDSForest -DomainName "$Domain" -InstallDns 

# Add DNS entries
$DnsCsv = Import-Csv ".\Records\DNS_Records.csv"
foreach ($Entry in $DnsCsv) {
    $EntryIP = $Entry.IP
    $EntryHostname = $Entry.Hostname

    # Make sure that the DNS Record doesn't already exist
    if (Resolve-DnsName -Name $EntryHostname -Server "$ServerFQDN") {
        Write-Warning "DNS Record for $EntryHostname Already Exists"
    }
    else {
        Add-DnsServerResourceRecordA `
        -Name "$EntryHostname" `
        -ZoneName "$Domain" `
        -AllowUpdateAny `
        -IPv4Address "$EntryIP" `
        -TimeToLive 01:00:00 `
        -ZoneName "$Domain"
    }
}

# Add a DNS forwarder
Add-DnsServerForwarder -IPAddress $CloudflareIP -PassThru

# Create a group for devices that users can access, these will be added once they are enrolled
New-ADGroup -Name "DevelopmentWorkstations" -GroupScope Global -GroupCategory Security

Read-Host "Press Enter to exit"
