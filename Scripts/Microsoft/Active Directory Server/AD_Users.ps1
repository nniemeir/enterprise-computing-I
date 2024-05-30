. .\..\preferences.ps1

if(!(Test-Path -Path ".\Reports")) {
New-Item -Path ".\Reports" -ItemType directory 
}

$UserCsv = Import-Csv ".\Records\Users_Developers.csv" -Delimiter ";"
foreach ($User in $UserCsv) {
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $Username = $User.Username
    $Email = $User.Email
    $JobTitle = $User.JobTitle
    # Make sure that the user doesn't already exist
    if (Get-ADUser -Filter { SamAccountName -eq $Username }) {
        Write-Warning "User $Username already exists"
    }
    else {
        # Generate a temporary password for the user
        Add-Type -AssemblyName 'System.Web'
        $Length = Get-Random -Minimum 12 -Maximum 20
        $MaxNonAlphanum = $Length - 4
        $NonAlphaNum = Get-Random -Minimum 5 -Maximum $MaxNonAlphanum
        $TempPassword=[System.Web.Security.Membership]::GeneratePassword($Length,$NonAlphaNum)
        # The user's temporary password is written to a text file, this would be printed and given to them
        "$TempPassword" | Out-File -FilePath ".\Reports\$Username.txt"
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@$Domain" `
            -Name "$FirstName $LastName" `
            -GivenName $FirstName `
            -Surname $LastName `
            -Enabled $True `
            -DisplayName "$LastName, $FirstName" `
            -EmailAddress $Email `
            -Title $JobTitle `
            -AccountPassword (ConvertTo-secureString $TempPassword -AsPlainText -Force) -ChangePasswordAtLogon $True `
            -LogonWorkstations "$DevStationHostname"

            
        Write-Host "Created user $Username"
    }
}

$DesktopAdminsCsv = Import-Csv ".\Records\Users_Desktop_Admins.csv" -Delimiter ";"
foreach ($dAdmin in $DesktopAdminsCsv) {
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $Username = $User.Username
    $Email = $User.Email
    $JobTitle = $User.JobTitle
    # Make sure that the user doesn't already exist
    if (Get-ADUser -Filter { SamAccountName -eq $Username }) {
        Write-Warning "User $Username already exists"
    }
    else {
        # Generate a temporary password for the user
        Add-Type -AssemblyName 'System.Web'
        $Length = Get-Random -Minimum 12 -Maximum 20
        $MaxNonAlphanum = $Length - 4
        $NonAlphaNum = Get-Random -Minimum 5 -Maximum $MaxNonAlphanum
        $TempPassword=[System.Web.Security.Membership]::GeneratePassword($Length,$NonAlphaNum)
        # The user's temporary password is written to a text file, this would be printed and given to them
        "$TempPassword" | Out-File -FilePath ".\Reports\$Username Temporary.txt"
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@$Domain" `
            -Name "$FirstName $LastName" `
            -GivenName $FirstName `
            -Surname $LastName `
            -Enabled $True `
            -DisplayName "$LastName, $FirstName" `
            -EmailAddress $Email `
            -Title $JobTitle `
            -AccountPassword (ConvertTo-secureString $TempPassword -AsPlainText -Force) -ChangePasswordAtLogon $True `
            -MemberOf "Administrators" `
            -LogonWorkstations "$DevStationHostname"
            
        Write-Host "Created user $Username"
    }
    }
Read-Host "Press Enter to exit"
