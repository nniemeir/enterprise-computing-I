# Copy ADMX templates to domain controller and domain member
Copy-Item -Path ".\Group Policy\Templates\Windows Server 2022\*" -Destination "C:\Windows\PolicyDefinitions\" -Recurse
Copy-Item -Path ".\Group Policy\Templates\Windows 11\*" -Destination "C:\Windows\PolicyDefinitions\" -ToSession (New-PSSession -ComputerName PASSENGER01) -Recurse

Invoke-WebRequest "https://github.com/mozilla/policy-templates/releases/download/v5.2/policy_templates_v5.2.zip" -OutFile ".\policy_templates.zip"
Expand-Archive -Path ".\policy_templates.zip" -DestinationPath ".\policies\"
Move-Item -Path ".\policies\windows\*" -Destination "C:\Windows\PolicyDefinitions"
Move-Item -Path ".\policies\windows\en-US\*" -Destination "C:\Windows\PolicyDefinitions\en-US" -Recurse
rm ".\policies\" -r -force
rm ".\policy_templates.zip" -force

# Firefox ADMX templates are installed on development workstation in the Dev_Toolkit script
 
# Import GPO Backups
$GPOLocation = "C:\Users\Administrator\Project Files\Group Policy\GPO"
Import-GPO -BackupID "FCEAB0DA-7ACA-46AB-8845-5EE6AA969FD8" -Path $GPOLocation -TargetName "Default Domain Policy" -CreateIfNeeded
Import-GPO -BackupID "ED5CDF36-864B-4689-8BBE-05E2FA06251D" -Path $GPOLocation -TargetName "Default Domain Controllers Policy" -CreateIfNeeded
Import-GPO -BackupID "9F51DA68-2CC1-476E-BCF1-08341EF23CA9" -Path $GPOLocation -TargetName "MSFT Windows Server 2022 - Defender Antivirus" -CreateIfNeeded
Import-GPO -BackupID "A0F74716-D627-4BBF-BBF7-0F69090694A8" -Path $GPOLocation -TargetName "MSFT Windows Server 2022 - Domain Controller" -CreateIfNeeded
Import-GPO -BackupID "0A8E00FD-4D87-4D5D-B059-E8C7735EDE30" -Path $GPOLocation -TargetName "MSFT Windows 11 22H2 - BitLocker" -CreateIfNeeded
Import-GPO -BackupID "BC368BB1-830B-40E0-917A-071D214F72B6" -Path $GPOLocation -TargetName "MSFT Windows 11 22H2 - Computer" -CreateIfNeeded
Import-GPO -BackupID "85AE3D79-FC2B-4A9D-9283-4F1B237DEF7B" -Path $GPOLocation -TargetName "MSFT Windows 11 22H2 - Defender Antivirus" -CreateIfNeeded
Import-GPO -BackupID "DE60BED9-ACEB-4D50-B276-393776E0BC6F" -Path $GPOLocation -TargetName "MSFT Windows 11 22H2 - User" -CreateIfNeeded
Import-GPO -BackupID "C680BCEF-4ACC-441B-BA7D-ADEDBCB7F940" -Path $GPOLocation -TargetName "Firefox" -CreateIfNeeded
Import-GPO -BackupID "77043E0B-CB1D-40CE-88EF-BA6B82B44A89" -Path $GPOLocation -TargetName "Password Policy" -CreateIfNeeded

# Set Security Filtering for imported GPO backups
Get-GPO -Name 'MSFT Windows Server 2022 - Defender Antivirus' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows Server 2022 - Defender Antivirus' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'STATION' -TargetType computer 
New-GPLink -Name 'MSFT Windows Server 2022 - Defender Antivirus' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows Server 2022 - Domain Controller' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows Server 2022 - Domain Controller' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'STATION' -TargetType computer 
New-GPLink -Name 'MSFT Windows Server 2022 - Domain Controller' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - BitLocker' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - BitLocker' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'PASSENGER01' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - Bitlocker' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - Computer' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - Computer' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'PASSENGER01' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - Computer' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - Defender Antivirus' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - Defender Antivirus' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'PASSENGER01' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - Defender Antivirus' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'MSFT Windows 11 22H2 - User' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'MSFT Windows 11 22H2 - User' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'PASSENGER01' -TargetType computer 
New-GPLink -Name 'MSFT Windows 11 22H2 - User' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Get-GPO -Name 'Firefox' | Set-GPPermissions -Replace -PermissionLevel None -TargetName 'Authenticated Users' -TargetType group 
Get-GPO -Name 'Firefox' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'PASSENGER01' -TargetType computer 
New-GPLink -Name 'Firefox' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes

Get-GPO -Name 'Password Policy' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'STATION' -TargetType computer 
Get-GPO -Name 'Password Policy' | Set-GPPermissions -PermissionLevel gpoapply -TargetName 'PASSENGER01' -TargetType computer 
New-GPLink -Name 'Password Policy' -Target "dc=universalnoodles,dc=lan" -LinkEnabled Yes


Read-Host "Press Enter to exit"
