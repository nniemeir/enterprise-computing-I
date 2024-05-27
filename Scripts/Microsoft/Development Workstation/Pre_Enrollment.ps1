. .\..\preferences.ps1

# Set the device's IP and Gateway
New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress $DevStationIP `
    -PrefixLength 24 `
    -DefaultGateway $PfSenseIP

# Set DNS
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses $ServerIP

# Set hostname
Rename-Computer -NewName "$DevStationHostname" -Force -PassThru

# Apply network configuration changes
Restart-NetAdapter -Name Ethernet

# Reboot
Restart-Computer
