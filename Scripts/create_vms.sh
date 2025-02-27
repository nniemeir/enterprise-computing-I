#!/bin/bash

main() {
	local vm_parent_path
	read -p "Enter desired VM parent directory (leave empty for home directory): " vm_parent_path
	local vm_path
	vm_path=validate_vm_parent_dir "$vm_parent_path"

	# pfSense does not support Secure Boot as of writing
	new_vm "$vm_path" "RH_pfSense" "FreeBSD_64" 2 "VMSVGA" 4096 64000 true "linux" false
	new_vm "$vm_path" "RH_freeIPA" "Fedora_64" 2 "VMSVGA" 8192 64000 false "linux" true
	new_vm "$vm_path" "RH_Ansible" "Fedora_64" 2 "VMSVGA" 2048 64000 false "linux" true
	new_vm "$vm_path" "RH_DevStation" "Fedora_64" 2 "VMSVGA" 4096 64000 false "linux" true
	new_vm "$vm_path" "MS_pfSense" "FreeBSD_64" 2 "VMSVGA" 4096 64000 true "windows" false
	new_vm "$vm_path" "MS_AD_Server" "Windows2022_64" 2 "VBoxSVGA" 8192 100000 true "windows" true
	new_vm "$vm_path" "MS_DevStation" "Windows11_64" 2 "VBoxSVGA" 8192 80000 true "windows" true
}

validate_vm_parent_dir() {
	local vm_parent_path
	vm_parent_path="$1"

	if [[ -z "$vm_parent_path" ]]; then
		vm_parent_path="$HOME"
	fi

	# Remove trailing forward slash on path if present
	if [ "${vm_parent_path: -1}" == "/" ]; then
		vm_parent_path="${vm_parent_path%/*}"
	fi

	local vm_path="$vm_parent_path/Enterprise Computing I VMs"

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
	
	echo "$vm_path"
}

new_vm() {
	local vm_path="$1"
	local vm_name="$2"
	local os_type="$3"
	local cpus="$4"
	local graphics_controller="$5"
	local memory_size="$6"
	local storage_size="$7"
	local is_firewall="$8"
	local internal_network="$9"
	local efi_enabled="$10"

	VBoxManage createvm --name "$vm_name" --ostype "$os_type" --register --basefolder "$vm_path"
	VBoxManage modifyvm "$vm_name" --memory "$memory_size" --vram 128
	VBoxManage modifyvm "$vm_name" --graphicscontroller "$graphics_controller"
	VBoxManage modifyvm "$vm_name" --audio-enabled off

	if [ "$is_firewall" = true ]; then
		VBoxManage modifyvm "$vm_name" --nic1 nat
		VBoxManage modifyvm "$vm_name" --nic2 intnet
		VBoxManage modifyvm "$vm_name" --intnet2 $internal_network
	else
		VBoxManage modifyvm "$vm_name" --nic1 intnet
		VBoxManage modifyvm "$vm_name" --intnet1 "$internal_network"
	fi

	if [ "$efi_enabled" = true ]; then
		VBoxManage modifyvm "$vm_name" --firmware efi64
		VBoxManage modifynvram "$vm_name" inituefivarstore
		VBoxManage modifynvram "$vm_name" enrollmssignatures
		VBoxManage modifynvram "$vm_name" enrollorclpk
	fi

	VBoxManage modifyvm "$vm_name" --cpus $cpus
	VBoxManage createhd --filename "$vm_path"/"$vm_name"/"$vm_name".vdi --size $storage_size --format VDI
	VBoxManage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci
	VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vm_path"/"$vm_name"/"$vm_name".vdi
}

main "$@"
