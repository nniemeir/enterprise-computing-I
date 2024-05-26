
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

if (Test-Path -Path "$VMPath\RH_pfSense") {
	Write-Host "A deployment already exists in this location"
	exit 1
}

function New-VM {
$vmName = $args[0]
$osType = $args[1]
$cpus = $args[2]
$memorySize = $args[3]
$storageSize = $args[4]
$isFirewall = $args[5]
$internalNetwork = $args[6]
$EFIEnabled = $args[7]

VBoxManage createvm --name "$vmName" --ostype "$osType" --register --basefolder "$VMPath" 
VBoxManage modifyvm "$vmName" --memory "$memorySize" --vram 128
VBoxManage modifyvm "$vmName" --graphicscontroller vmsvga
if ( $isFirewall -eq $true) {
VBoxManage modifyvm "$vmName" --nic1 nat 
VBoxManage modifyvm "$vmName" --nic2 intnet 
VBoxManage modifyvm "$vmName" --intnet2 $internalNetwork
} else {
VBoxManage modifyvm "$vmName" --nic1 intnet 
VBoxManage modifyvm "$vmName" --intnet1 "$internalNetwork"
}

if ( $EFIEnabled -eq $true) {
VBoxManage modifyvm "$vmName" --firmware efi64 
VBoxManage modifynvram "$vmName" inituefivarstore
VBoxManage modifynvram "$vmName" enrollmssignatures
VBoxManage modifynvram "$vmName" enrollorclpk
}

VBoxManage modifyvm "$vmName" --cpus $cpus
VBoxManage createhd --filename "$VMPath\$vmName\$vmName.vdi" --size $storageSize --format VDI                     
VBoxManage storagectl "$vmName" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "$vmName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $VMPath\$vmName\$vmName.vdi 
}

# pfSense does not support Secure Boot as of writing
New-VM "RH_pfSense" "FreeBSD_64" 2 4096 64000 $true "linux" $false

New-VM "RH_freeIPA" "Fedora_64" 2 8192 64000 $false "linux" $true 

New-VM "RH_Ansible" "Fedora_64" 2 2048 64000 $false "linux" $true

New-VM "RH_DevStation" "Fedora_64" 2 4096 64000 $false "linux" $true

New-VM "MS_pfSense" "FreeBSD_64" 2 4096 64000 $true "windows" $false

New-VM "MS_AD_Server" "Windows2022_64" 2 8192 100000 $true "windows" $true

New-VM "MS_DevStation" "Windows11_64" 2 8192 80000 $true "windows" $true
