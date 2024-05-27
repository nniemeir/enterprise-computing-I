
$VMParentPath = Read-Host "Enter desired VM parent directory (leave empty for home directory): "

if (-not($VMParentPath)) {
    $VMParentPath = $env:USERPROFILE
}

# Remove trailing forward slash if present
if ($VMParentPath -match '\\$' ) {
	$VMParentPath = $VMParentPath.Substring(0,$VMParentPath.Length-1)
}

$VMPath="$VMParentPath\Enterprise Computing I VMs"

if (-not(New-Item -Path "$VMParentPath" -Name writable -ItemType "file" -Value "Test")) {
	Write-Host "Unable to access the directory. Please ensure that you have write access"
	exit 1
}
else {
Remove-Item "$VMParentPath\writable"
}

if (Test-Path -Path "$VMPath\RH_pfSense") {
	Write-Host "A deployment already exists in this location"
	exit 1
}

function New-VM {
$VMName = $args[0]
$OSType = $args[1]
$CPUs = $args[2]
$MemorySize = $args[3]
$StorageSize = $args[4]
$IsFirewall = $args[5]
$InternalNetwork = $args[6]
$EFIEnabled = $args[7]

VBoxManage createvm --name "$VMName" --ostype "$OSType" --register --basefolder "$VMPath" 
VBoxManage modifyvm "$VMName" --memory "$MemorySize" --vram 128
VBoxManage modifyvm "$VMName" --graphicscontroller vmsvga
if ( $IsFirewall -eq $true) {
VBoxManage modifyvm "$VMName" --nic1 nat 
VBoxManage modifyvm "$VMName" --nic2 intnet 
VBoxManage modifyvm "$VMName" --intnet2 $InternalNetwork
} else {
VBoxManage modifyvm "$VMName" --nic1 intnet 
VBoxManage modifyvm "$VMName" --intnet1 "$InternalNetwork"
}

if ( $EFIEnabled -eq $true) {
VBoxManage modifyvm "$VMName" --firmware efi64 
VBoxManage modifynvram "$VMName" inituefivarstore
VBoxManage modifynvram "$VMName" enrollmssignatures
VBoxManage modifynvram "$VMName" enrollorclpk
}

VBoxManage modifyvm "$VMName" --cpus $CPUs
VBoxManage createhd --filename "$VMPath\$VMName\$VMName.vdi" --size $StorageSize --format VDI                     
VBoxManage storagectl "$VMName" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "$VMName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $VMPath\$VMName\$VMName.vdi 
}

# pfSense does not support Secure Boot as of writing
New-VM "RH_pfSense" "FreeBSD_64" 2 4096 64000 $true "linux" $false

New-VM "RH_freeIPA" "Fedora_64" 2 8192 64000 $false "linux" $true 

New-VM "RH_Ansible" "Fedora_64" 2 2048 64000 $false "linux" $true

New-VM "RH_DevStation" "Fedora_64" 2 4096 64000 $false "linux" $true

New-VM "MS_pfSense" "FreeBSD_64" 2 4096 64000 $true "windows" $false

New-VM "MS_AD_Server" "Windows2022_64" 2 8192 100000 $true "windows" $true

New-VM "MS_DevStation" "Windows11_64" 2 8192 80000 $true "windows" $true
