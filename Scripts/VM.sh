#!/bin/bash

read -p "Enter desired VM parent directory (leave empty for home directory): " VMParentPath

if [[ -z "$VMParentPath" ]]; then
    VMParentPath="$HOME"
fi

# Remove trailing forward slash if present
if [ "${VMParentPath: -1}" == "/" ]; then 
	VMParentPath="${VMParentPath%/*}"
fi

VMPath="$VMParentPath/Enterprise Computing I VMs"

# Ensure parent directory is writeable before proceeding
if [ ! -w "$VMParentPath" ]; then 
	echo "Unable to access the directory. Please ensure that you have write access"
	exit 1
fi

# Ensure VMs not deployed already
if [ -d "$VMPath/RH_pfSense" ]; then
	echo "A deployment already exists in this location"
	exit 1
fi

setupVM() {
local vmName="$1"
local osType="$2"
local cpus="$3"
local memorySize="$4"
local storageSize="$5"
local isFirewall="$6"
local internalNetwork="$7"
local EFIEnabled="$8"

VBoxManage createvm --name "$vmName" --ostype "$osType" --register --basefolder "$VMPath" 
VBoxManage modifyvm "$vmName" --memory "$memorySize" --vram 128
VBoxManage modifyvm "$vmName" --graphicscontroller vmsvga
if [ "$isFirewall" = true ] ; then
VBoxManage modifyvm "$vmName" --nic1 nat 
VBoxManage modifyvm "$vmName" --nic2 intnet 
VBoxManage modifyvm "$vmName" --intnet2 $internalNetwork
else 
VBoxManage modifyvm "$vmName" --nic1 intnet 
VBoxManage modifyvm "$vmName" --intnet1 "$internalNetwork"
fi

if [ "$EFIEnabled" = true ] ; then
VBoxManage modifyvm "$vmName" --firmware efi64 
VBoxManage modifynvram "$vmName" inituefivarstore
VBoxManage modifynvram "$vmName" enrollmssignatures
VBoxManage modifynvram "$vmName" enrollorclpk
fi

VBoxManage modifyvm "$vmName" --cpus $cpus
VBoxManage createhd --filename "$VMPath"/"$vmName"/"$vmName".vdi --size $storageSize --format VDI                     
VBoxManage storagectl "$vmName" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "$vmName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VMPath"/"$vmName"/"$vmName".vdi 
}

# pfSense does not support Secure Boot as of writing
setupVM "RH_pfSense" "FreeBSD_64" 2 4096 64000 true "linux" false

setupVM "RH_freeIPA" "Fedora_64" 2 8192 64000 false "linux" true 

setupVM "RH_Ansible" "Fedora_64" 2 2048 64000 false "linux" true

setupVM "RH_DevStation" "Fedora_64" 2 4096 64000 false "linux" true

setupVM "MS_pfSense" "FreeBSD_64" 2 4096 64000 true "windows" false

setupVM "MS_AD_Server" "Windows2022_64" 2 8192 100000 true "windows" true

setupVM "MS_DevStation" "Windows11_64" 2 8192 80000 true "windows" true
