#!/bin/bash

read -p "Enter desired VM parent directory (leave empty for home directory): " vm_parent_path

if [[ -z "$vm_parent_path" ]]; then
    vm_parent_path="$HOME"
fi

# Remove trailing forward slash if present
if [ "${vm_parent_path: -1}" == "/" ]; then 
	vm_parent_path="${vm_parent_path%/*}"
fi

vm_path="$vm_parent_path/Enterprise Computing I VMs"

# Ensure parent directory is writeable before proceeding
if [ ! -w "$vm_parent_path" ]; then 
	echo "Unable to access the directory. Please ensure that you have write access"
	exit 1
fi

# Ensure VMs not deployed already
if [ -d "$vm_path/RH_pfSense" ]; then
	echo "A deployment already exists in this location"
	exit 1
fi

setup_vm() {
local vm_name="$1"
local os_type="$2"
local cpus="$3"
local graphics_controller="$4"
local memory_size="$5"
local storage_size="$6"
local is_firewall="$7"
local internal_network="$8"
local efi_enabled="$9"

VBoxManage createvm --name "$vm_name" --ostype "$os_type" --register --basefolder "$vm_path" 
VBoxManage modifyvm "$vm_name" --memory "$memory_size" --vram 128
VBoxManage modifyvm "$vm_name" --graphicscontroller "$graphics_controller"
if [ "$is_firewall" = true ] ; then
VBoxManage modifyvm "$vm_name" --nic1 nat 
VBoxManage modifyvm "$vm_name" --nic2 intnet 
VBoxManage modifyvm "$vm_name" --intnet2 $internal_network
else 
VBoxManage modifyvm "$vm_name" --nic1 intnet 
VBoxManage modifyvm "$vm_name" --intnet1 "$internal_network"
fi

if [ "$efi_enabled" = true ] ; then
VBoxManage modifyvm "$vm_name" --firmware efi64 
VBoxManage modifynvram "$vm_name" inituefivarstore
VBoxManage modifynvram "$vm_name" enrollmssignatures
VBoxManage modifynvram "$vm_name" enrollorclpk
fi

VBoxManage modifyvm "$vm_name" --cpus $cpus
VBoxManage createhd --filename "$vm_path"/"$vm_name"/"$vm_name".vdi --size $storage_size --format VDI                     
VBoxManage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$vm_path"/"$vm_name"/"$vm_name".vdi 
}

# pfSense does not support Secure Boot as of writing
setup_vm "RH_pfSense" "FreeBSD_64" 2 "VMSVGA" 4096 64000 true "linux" false

setup_vm "RH_freeIPA" "Fedora_64" 2 "VMSVGA" 8192 64000 false "linux" true 

setup_vm "RH_Ansible" "Fedora_64" 2 "VMSVGA" 2048 64000 false "linux" true

setup_vm "RH_DevStation" "Fedora_64" 2 "VMSVGA" 4096 64000 false "linux" true

setup_vm "MS_pfSense" "FreeBSD_64" 2 "VMSVGA" 4096 64000 true "windows" false

setup_vm "MS_AD_Server" "Windows2022_64" 2 "VBoxSVGA" 8192 100000 true "windows" true

setup_vm "MS_DevStation" "Windows11_64" 2 "VBoxSVGA" 8192 80000 true "windows" true
