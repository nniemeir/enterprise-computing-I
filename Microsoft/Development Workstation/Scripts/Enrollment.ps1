# Join device to domain
Write-Host "This system will now be joined to the domain, it will reboot on completion of this task"
Add-Computer -DomainName universalnoodles.lan -Credential jcarpenter -Restart -Force

