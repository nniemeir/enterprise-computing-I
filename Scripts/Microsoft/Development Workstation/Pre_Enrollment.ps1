# Set the device's IP and Gateway
New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress 173.16.16.3 `
    -PrefixLength 16 `
    -DefaultGateway 173.16.16.1

# Set DNS
Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses 173.16.16.2

# Set hostname
Rename-Computer -NewName "passenger01" -Force -PassThru

# Apply network configuration changes
Restart-NetAdapter -Name Ethernet

# Reboot
Restart-Computer
