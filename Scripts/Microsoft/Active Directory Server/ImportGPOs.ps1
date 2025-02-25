. .\..\preferences.ps1

$GPODir = ".\GPO"
$GPOTemplateDir = ".\GPO\Templates"

# Make templates directory if it doesn't already exist
if(!(Test-Path -Path ".\GPO\Templates")) {
New-Item -Path ".\GPO\Templates" -ItemType directory 
}

# Download Microsoft Security Baseline GPO templates
Invoke-WebRequest "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%20Server%202022%20Security%20Baseline.zip" -OutFile "$GPOTemplateDir\WS2022_Baselines.zip"
Invoke-WebRequest "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/Windows%2011%20Security%20Baseline.zip" -OutFile "$GPOTemplateDir\W11_Baselines.zip"

Expand-Archive -Path "$GPOTemplateDir\W11_Baselines.zip" -DestinationPath "$GPOTemplateDir\Windows 11 Baselines"
Expand-Archive -Path "$GPOTemplateDir\WS2022_Baselines.zip" -DestinationPath "$GPOTemplateDir\Windows Server Baselines"

# Copy ADMX templates to domain controller and domain member
Copy-Item -Path "$GPOTemplateDir\Windows 11 Baselines\Templates\*" -Destination "C:\Windows\PolicyDefinitions\" -Recurse
Copy-Item -Path "$GPOTemplateDir\Windows Server 2022 Baselines\Templates\*" -Destination "C:\Windows\PolicyDefinitions\" -ToSession (New-PSSession -ComputerName $DevStationHostname) -Recurse
 
# Import GPO Backups
Import-GPO -BackupID "FCEAB0DA-7ACA-46AB-8845-5EE6AA969FD8" -Path $GPODir -TargetName "Default Domain Policy" -CreateIfNeeded
Import-GPO -BackupID "ED5CDF36-864B-4689-8BBE-05E2FA06251D" -Path $GPODir -TargetName "Default Domain Controllers Policy" -CreateIfNeeded
Import-GPO -BackupID "9F51DA68-2CC1-476E-BCF1-08341EF23CA9" -Path $GPODir -TargetName "MSFT Windows Server 2022 - Defender Antivirus" -CreateIfNeeded
Import-GPO -BackupID "A0F74716-D627-4BBF-BBF7-0F69090694A8" -Path $GPODir -TargetName "MSFT Windows Server 2022 - Domain Controller" -CreateIfNeeded
Import-GPO -BackupID "0A8E00FD-4D87-4D5D-B059-E8C7735EDE30" -Path $GPODir -TargetName "MSFT Windows 11 22H2 - BitLocker" -CreateIfNeeded
Import-GPO -BackupID "BC368BB1-830B-40E0-917A-071D214F72B6" -Path $GPODir -TargetName "MSFT Windows 11 22H2 - Computer" -CreateIfNeeded
Import-GPO -BackupID "85AE3D79-FC2B-4A9D-9283-4F1B237DEF7B" -Path $GPODir -TargetName "MSFT Windows 11 22H2 - Defender Antivirus" -CreateIfNeeded
Import-GPO -BackupID "DE60BED9-ACEB-4D50-B276-393776E0BC6F" -Path $GPODir -TargetName "MSFT Windows 11 22H2 - User" -CreateIfNeeded
Import-GPO -BackupID "C680BCEF-4ACC-441B-BA7D-ADEDBCB7F940" -Path $GPODir -TargetName "Firefox" -CreateIfNeeded
Import-GPO -BackupID "77043E0B-CB1D-40CE-88EF-BA6B82B44A89" -Path $GPODir -TargetName "Password Policy" -CreateIfNeeded

# Set Security Filtering for imported GPO backups
Get-GPO -Name 'MSFT Windows Server 2022 - Defender Antivirus' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows Server 2022 - Defender Antivirus' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$ServerHostname' -TargetType computer 
New-GPLink -Name 'MSFT Windows Server 2022 - Defender Antivirus' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows Server 2022 - Domain Controller' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows Server 2022 - Domain Controller' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$ServerHostname' -TargetType computer 
New-GPLink -Name 'MSFT Windows Server 2022 - Domain Controller' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - BitLocker' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - BitLocker' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$DevStationHostname' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - Bitlocker' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - Computer' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - Computer' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$DevStationHostname' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - Computer' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - Defender Antivirus' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - Defender Antivirus' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$DevStationHostname' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - Defender Antivirus' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - User' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - User' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$DevStationHostname' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - User' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'Firefox' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'Firefox' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$DevStationHostname' -TargetType computer 
New-GPLink -Name 'Firefox' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes

Get-GPO -Name 'Password Policy' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$ServerHostname' -TargetType computer 
Get-GPO -Name 'Password Policy' | Set-GPPermissions -PermissionLevel gpoapply -TargetName '$DevStationHostname' -TargetType computer 
New-GPLink -Name 'Password Policy' -Target "dc=$Domain,dc=lan" -LinkEnabled Yes


Read-Host "Press Enter to exit"
