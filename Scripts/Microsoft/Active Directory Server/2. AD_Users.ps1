$UserCSV = Import-Csv ".\Records\Users_Developers.csv" -Delimiter ";"
foreach ($User in $UserCSV) {
    $firstname = $User.firstname
    $lastname = $User.lastname
    $username = $User.username
    $email = $User.email
    $jobtitle = $User.jobtitle
    # Make sure that the user doesn't already exist
    if (Get-ADUser -Filter { SamAccountName -eq $username }) {
        Write-Warning "User $username already exists"
    }
    else {
        # Generate a temporary password for the user
        Add-Type -AssemblyName 'System.Web'
        $length = Get-Random -Minimum 12 -Maximum 20
        $maxNonAlphanum = $length - 4
        $nonAlphanum = Get-Random -Minimum 5 -Maximum $maxNonAlphanum
        $tempPassword=[System.Web.Security.Membership]::GeneratePassword($length,$nonAlphaNum)
        # The user's temporary password is written to a text file, this would be printed and given to them
        "$tempPassword" | Out-File -FilePath ".\Reports\$username Temporary.txt"
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$universalnoodles.lan" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Enabled $True `
            -DisplayName "$lastname, $firstname" `
            -EmailAddress $email `
            -Title $jobtitle `
            -AccountPassword (ConvertTo-secureString $tempPassword -AsPlainText -Force) -ChangePasswordAtLogon $True `
            -LogonWorkstations "PASSENGER01"

            
        Write-Host "Created user $username"
    }
}

$dAdminsCSV = Import-Csv ".\Records\Users_Desktop_Admins.csv" -Delimiter ";"
foreach ($dAdmin in $dAdminsCSV) {
    $firstname = $User.firstname
    $lastname = $User.lastname
    $username = $User.username
    $email = $User.email
    $jobtitle = $User.jobtitle
    # Make sure that the user doesn't already exist
    if (Get-ADUser -Filter { SamAccountName -eq $username }) {
        Write-Warning "User $username already exists"
    }
    else {
        # Generate a temporary password for the user
        Add-Type -AssemblyName 'System.Web'
        $length = Get-Random -Minimum 12 -Maximum 20
        $maxNonAlphanum = $length - 4
        $nonAlphanum = Get-Random -Minimum 5 -Maximum $maxNonAlphanum
        $tempPassword=[System.Web.Security.Membership]::GeneratePassword($length,$nonAlphaNum)
        # The user's temporary password is written to a text file, this would be printed and given to them
        "$tempPassword" | Out-File -FilePath ".\Reports\$username Temporary.txt"
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$universalnoodles.lan" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Enabled $True `
            -DisplayName "$lastname, $firstname" `
            -EmailAddress $email `
            -Title $jobtitle `
            -AccountPassword (ConvertTo-secureString $tempPassword -AsPlainText -Force) -ChangePasswordAtLogon $True `
            -MemberOf "Administrators" `
            -LogonWorkstations "PASSENGER01"
            
        Write-Host "Created user $username"
    }
    }
Read-Host "Press Enter to exit"