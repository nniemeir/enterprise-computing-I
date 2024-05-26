. .\..\preferences.ps1

# Allow ping
New-NetFirewallRule -DisplayName "ICMPv4 Echo Request" -Protocol ICMPv4 -IcmpType 8 -Action Allow

# Configure WinRM
winrm qc

# Add Desktop Admin to local administrators
net localgroup Administrators /add $Domain\$EnrollUser

# Update GP
gpupdate /force
