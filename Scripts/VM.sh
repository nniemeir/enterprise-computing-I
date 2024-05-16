#!/bin/bash
VM_PATH="/mnt/media/VMs"

VBoxManage createvm --name "RH_pfSense" --ostype "FreeBSD_64" --register --basefolder "$VM_PATH" 
VBoxManage modifyvm "RH_pfSense" --memory 4096 --vram 128
VBoxManage modifyvm "RH_pfSense" --graphicscontroller vmsvga
VBoxManage modifyvm "RH_pfSense" --nic1 nat 
VBoxManage modifyvm "RH_pfSense" --nic2 intnet 
VBoxManage modifyvm "RH_pfSense" --intnet2 "linux"
VBoxManage modifyvm "RH_pfSense" --cpus 2
VBoxManage createhd --filename "$VM_PATH"/"RH_pfSense"/"RH_pfSense".vdi --size 64000 --format VDI                     
VBoxManage storagectl "RH_pfSense" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "RH_pfSense" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"RH_pfSense"/"RH_pfSense".vdi            

VBoxManage createvm --name "RH_freeIPA" --ostype "Fedora_64" --register --basefolder "$VM_PATH" 
VBoxManage modifyvm "RH_freeIPA" --memory 8192 --vram 128
VBoxManage modifyvm "RH_freeIPA" --graphicscontroller vmsvga
VBoxManage modifyvm "RH_freeIPA" --nic1 intnet 
VBoxManage modifyvm "RH_freeIPA" --intnet1 "linux"
VBoxManage modifyvm "RH_freeIPA" --cpus 2
VBoxManage createhd --filename "$VM_PATH"/"RH_freeIPA"/"RH_freeIPA".vdi --size 64000 --format VDI                     
VBoxManage storagectl "RH_freeIPA" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "RH_freeIPA" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"RH_freeIPA"/"RH_freeIPA".vdi            
VBoxManage modifyvm "RH_freeIPA" --firmware efi64 
VBoxManage modifynvram "RH_freeIPA" inituefivarstore
VBoxManage modifynvram "RH_freeIPA" enrollmssignatures
VBoxManage modifynvram "RH_freeIPA" enrollorclpk

VBoxManage createvm --name "RH_Ansible" --ostype "Fedora_64" --register --basefolder "$VM_PATH" 
VBoxManage modifyvm "RH_Ansible" --memory 2048 --vram 128
VBoxManage modifyvm "RH_Ansible" --graphicscontroller vmsvga
VBoxManage modifyvm "RH_Ansible" --nic1 intnet 
VBoxManage modifyvm "RH_Ansible" --intnet1 "linux"
VBoxManage modifyvm "RH_Ansible" --cpus 1
VBoxManage createhd --filename "$VM_PATH"/"RH_Ansible"/"RH_Ansible".vdi --size 64000 --format VDI                     
VBoxManage storagectl "RH_Ansible" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "RH_Ansible" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"RH_Ansible"/"RH_Ansible".vdi            
VBoxManage modifyvm "RH_Ansible" --firmware efi64 
VBoxManage modifynvram "RH_Ansible" inituefivarstore
VBoxManage modifynvram "RH_Ansible" enrollmssignatures
VBoxManage modifynvram "RH_Ansible" enrollorclpk

VBoxManage createvm --name "RH_DevStation" --ostype "Fedora_64" --register --basefolder "$VM_PATH" 
VBoxManage modifyvm "RH_DevStation" --memory 4096 --vram 128
VBoxManage modifyvm "RH_DevStation" --graphicscontroller vmsvga
VBoxManage modifyvm "RH_DevStation" --nic1 intnet 
VBoxManage modifyvm "RH_DevStation" --intnet1 "linux"
VBoxManage modifyvm "RH_DevStation" --cpus 2
VBoxManage createhd --filename "$VM_PATH"/"RH_DevStation"/"RH_DevStation".vdi --size 64000 --format VDI                     
VBoxManage storagectl "RH_DevStation" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "RH_DevStation" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"RH_DevStation"/"RH_DevStation".vdi            
VBoxManage modifyvm "RH_DevStation" --firmware efi64 
VBoxManage modifynvram "RH_DevStation" inituefivarstore
VBoxManage modifynvram "RH_DevStation" enrollmssignatures
VBoxManage modifynvram "RH_DevStation" enrollorclpk

VBoxManage createvm --name "MS_pfSense" --ostype "FreeBSD_64" --register --basefolder "$VM_PATH" 
VBoxManage modifyvm "MS_pfSense" --memory 4096 --vram 128
VBoxManage modifyvm "MS_pfSense" --graphicscontroller vmsvga
VBoxManage modifyvm "MS_pfSense" --nic1 nat 
VBoxManage modifyvm "MS_pfSense" --nic2 intnet 
VBoxManage modifyvm "MS_pfSense" --intnet2 "windows"
VBoxManage modifyvm "MS_pfSense" --cpus 2
VBoxManage createhd --filename "$VM_PATH"/"MS_pfSense"/"MS_pfSense".vdi --size 64000 --format VDI                     
VBoxManage storagectl "MS_pfSense" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "MS_pfSense" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"MS_pfSense"/"MS_pfSense".vdi            

VBoxManage createvm --name "MS_AD_Server" --ostype "Windows2022_64" --register --basefolder "$VM_PATH"
VBoxManage modifyvm "MS_AD_Server" --memory 8192 --vram 128
VBoxManage modifyvm "MS_AD_Server" --graphicscontroller vmsvga
VBoxManage modifyvm "MS_AD_Server" --nic1 intnet 
VBoxManage modifyvm "MS_AD_Server" --intnet1 "windows"
VBoxManage modifyvm "MS_AD_Server" --cpus 2
VBoxManage createhd --filename "$VM_PATH"/"MS_AD_Server"/"MS_AD_Server".vdi --size 100000 --format VDI                     
VBoxManage storagectl "MS_AD_Server" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "MS_AD_Server" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"MS_AD_Server"/"MS_AD_Server".vdi           
VBoxManage modifyvm "MS_AD_Server" --firmware efi64 
VBoxManage modifynvram "MS_AD_Server" inituefivarstore
VBoxManage modifynvram "MS_AD_Server" enrollmssignatures
VBoxManage modifynvram "MS_AD_Server" enrollorclpk

VBoxManage createvm --name "MS_DevStation" --ostype "Windows11_64" --register --basefolder "$VM_PATH" 
VBoxManage modifyvm "MS_DevStation" --memory 8192 --vram 128
VBoxManage modifyvm "MS_DevStation" --graphicscontroller vmsvga
VBoxManage modifyvm "MS_DevStation" --nic1 intnet 
VBoxManage modifyvm "MS_DevStation" --intnet1 "windows"
VBoxManage modifyvm "MS_DevStation" --cpus 2
VBoxManage createhd --filename "$VM_PATH"/"MS_DevStation"/"MS_DevStation".vdi --size 80000 --format VDI                     
VBoxManage storagectl "MS_DevStation" --name "SATA Controller" --add sata --controller IntelAhci       
VBoxManage storageattach "MS_DevStation" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$VM_PATH"/"MS_DevStation"/"MS_DevStation".vdi            
VBoxManage modifyvm "MS_DevStation" --firmware efi64 
VBoxManage modifynvram "MS_DevStation" inituefivarstore
VBoxManage modifynvram "MS_DevStation" enrollmssignatures
VBoxManage modifynvram "MS_DevStation" enrollorclpk
