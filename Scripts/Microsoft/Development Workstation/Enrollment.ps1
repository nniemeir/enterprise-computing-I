. .\..\preferences.ps1

# Join device to domain
Write-Host "This system will now be joined to the domain, it will reboot on completion of this task"
Add-Computer -DomainName $Domain -Credential $EnrollUser -Restart -Force

