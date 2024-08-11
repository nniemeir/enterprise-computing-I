### Preface
This guide will allow you to replicate the network of VMs that I configured for this project. A basic knowledge of Bash, PowerShell, and VirtualBox is assumed.

The deployment scripts assume a host system with specifications similar to the following:
* CPU: AMD Ryzen 7 5800x
* GPU: AMD RX 6600 XT
* RAM: 32GB DDR4
* Storage: 1TB (SSD strongly recommended) 

### Host Setup 
* Install Oracle VirtualBox 

* Run the script **VM.ps1** if you are on a Windows host or **VM.sh** if you are on a Linux host, this will create and configure the seven virtual machines.

* Download the following OS images:
    * [Fedora Server 40](https://fedoraproject.org/server/download)
    * [Fedora Workstation 40](https://fedoraproject.org/workstation/download)
    * [Windows Server 2022](https://www.microsoft.com/en-us/windows-server)
    * [Windows 11](https://www.microsoft.com/software-download/windows11)

### Microsoft Network

#### MS_pfSense
* Select the first interface listed as the WAN interface

* Select the second interface listed as the LAN interface

* Select continue at each prompt until reaching the **Active Subscription Validation** prompt.

* Select **Install CE**

* Accept the default filesystem and partition scheme

* At the **ZFS Configuration** prompt, select stripe

* Select default options in the next prompts, the VM will reboot on its own

* Once pfSense boots, select **Set interface(s) IP address**

* Select the LAN interface

* Select **n** when asked to configure the interface via DHCP

* Enter **173.16.16.1** as the LAN's IPv4 address

* Enter **28** as the subnet bit count

* Enter **n** when asked to configure interface via DHCP6

* Press enter to leave IPv6 address blank

* Enter **n** when asked to enable DHCP server on LAN

* Enter **n** when asked to revert to HTTP as the webConfigurator protocol

* Leave this VM on for the next VM setup

#### MS_AD
* Insert the Windows Server 2022 ISO 

* When setup begins, select **Windows Server 2022 Standard Evaluation (Desktop Experience)**

* Accept the license agreement

* Select **Custom** installation type

* Select **Drive 0**, the installation will now begin

* On first boot, enter the desired administrator password for this VM.

* On first login, open a PowerShell window with administrator privileges.

* Run the following command to change the hostname:
~~~
Rename-Computer -NewName "$DESIREDHOSTNAME" -Force -PassThru
~~~

* Reboot the VM

* On next login, right click the network icon in the taskbar and select **Open Network & Internet settings**. 

* Select **Change adapter options** under Advanced network settings

* Select the **Ethernet** adapter

* Select **Properties**

* Select **Internet Protocol Version 4 (TCP/IPv4)**

* Fill in the following settings
     * **IP address**: 173.16.16.2
     * **Subnet mask**: 255.255.255.240
     * **Default gateway**: 173.16.16.1
     * **Preferred DNS server**: 1.1.1.1

* Confirm the settings

* When prompted about allowing other devices to discover this one, select Yes.

* Download [Git](https://git-scm.com/downloads) using Microsoft Edge.

* Install Git with default options.

* Open Git Bash

* Run the following command to clone the project repository
~~~
git clone https://github.com/nniemeir/Enterprise-Computing-I
~~~

* Return to the **Internet Protocol Version 4 (TCP/IPv4)** properties menu

* Select **Obtain an IP address automatically**. 

* Clear the **Preferred DNS server** section

* Confirm the settings

* Open a PowerShell prompt with administrative privileges and navigate to the directory **Scripts\Microsoft\Active Directory Server** under the cloned repository.

* Run the following command to allow the deployment scripts to be run. 
~~~
Set-ExecutionPolicy unrestricted -scope Process
~~~

* Run the script **AD_Deploy**, this will install Active Directory Domain Services and add DNS records for each VM on the network as defined in DNS_Records.csv in the Records directory.

* You will be prompted to set a SafeModeAdministratorPassword, also known as the  Directory Services Restore Mode password.

* Choose A when prompted to confirm changes

* Run the script **AD_Users**, this will create privileged and unprivileged Active Directory users as defined in the files **Users_Desktop_Admins.csv** and **Users_Developers.csv** under the **Records** subdirectory.
Temporary passwords for each created user will be generated and saved in the **Reports** subdirectory.

* Follow the deployment instructions for MS_DevStation

* Run the script **AD_GPOs**, this will apply my altered versions of the Microsoft Security Baseline GPOs to MS_AD and MS_DevStation;the reasons for these alterations are explained (here)[Preface.md].

* Reboot both Windows VMs at this point. 

* Open a PowerShell prompt with administrative privileges and navigate to the directory **Scripts\Microsoft\Active Directory Server** under the cloned repository. 

* Run the following command to remotely install a set of development tools to MS_DevStation
~~~
Invoke-Command -ComputerName PASSENGER01 -FilePath Dev_Toolkit.ps1
~~~

* Check that the deployment of this network was successful by the criteria outlined [here](Testing.md)

#### MS_DevStation

* Insert the Windows 11 ISO 

* Disable both of the VM's network adapters

* Start the VM and select the following options
    * Next
    * Install Now
    * I don't have a product key
    * Windows 11 Pro
    * I accept the Microsoft Software License Terms...
    * Next
    * Custom: Install Windows only (advanced)
    * Drive 0 Unallocated Space
    * Next

* The installation will commence and the VM will reboot several times

* You will reach a screen with a prompt to select your country

* Type Shift+F10 to open a command prompt

* Enter the following command to bypass internet requirement for installation
~~~
OOBE\bypassnro
~~~

* The VM will reboot

* Select the following options
    * United States
    * Next
    * Skip
    * I don't have internet
    * Continue with limited setup

* You'll be asked to set a name and password for a local user

* Select No for all privacy settings and then Next

* When setup completes, shutdown the VM

* Renable the two network interfaces

* Start the VM

* Download [Git](https://git-scm.com/downloads) using Microsoft Edge.

* Install Git with default options.

* Open Git Bash

* Run the following command to clone the project repository
~~~
git clone https://github.com/nniemeir/Enterprise-Computing-I
~~~

* Open a PowerShell prompt with administrative privileges and navigate to the directory Scripts\Microsoft\Development Workstation under the cloned repository.

* Run the following command to allow the deployment scripts to be run.
~~~
Set-ExecutionPolicy unrestricted -scope Process 
~~~

* Run **Pre_Enrollment**, this will configure this device's network settings

* The VM will reboot on its own at this point

* Run **Enrollment**, this will join the host to the Active Directory domain. 

* The VM will reboot on its own again

* You will now be able to login to this device as any of the domain users we created

* Login as the local user once more

* Run **Post_Enrollment**, this will add the privileged domain users to the local administrators group on MS_DevStation and configure Windows Remote Management so that scripts targeting MS_DevStation can be run from MS_AD.

* Return to MS_AD.

### Red Hat Network

#### RH_pfSense

* Select the first interface listed as the WAN interface

* Select the second interface listed as the LAN interface

* Select continue at each prompt until reaching the **Active Subscription Validation** prompt.

* Select **Install CE**

* Accept the default filesystem and partition scheme

* At the **ZFS Configuration** prompt, select stripe

* Select default options in the next prompts, the VM will reboot on its own

* Once pfSense boots, select **Set interface(s) IP address**

* Select the LAN interface

* Select **n** when asked to configure the interface via DHCP

* Enter **172.16.16.1** as the LAN's IPv4 address

* Enter **28** as the subnet bit count

* Enter **n** when asked to configure interface via DHCP6

* Press enter to leave IPv6 address blank

* Enter **n** when asked to enable DHCP server on LAN

* Enter **n** when asked to revert to HTTP as the webConfigurator protocol

* Leave this VM on for the next VM setup

#### RH_FreeIPA

* Boot the VM from the Fedora Workstation 40 ISO

* Open Firefox

* Navigate to the pfSense web UI by typing its IP into the address bar, the current default login can be found in Netgate's documentation

* Select **Change the password in the User Manager**

* Enter a password of your choosing

* Select the save button at the bottom of the page

* Shutdown the VM

* Boot the VM from the Fedora Server 40 ISO

* Select **User Creation** and make a user

* Ensure that your locale is correct in the Time & Date menu

* Select **Network & Host Name**,

* Select **Configure**

* Select **IPv4 Settings**, Set method to manual, select add, set the address to 172.16.16.2, the Netmask to 255.255.255.240, and the gateway to 172.16.16.1. Set the DNS servers to 1.1.1.1. Set the Host Name to station.universalnoodles.lan. Toggle the interface. Click done

* Select Installation Destination, check **Encrypt my data** and **Free up space...** boxes and click done.

* Choose to delete all existing partitions.

* Enter an encryption passphrase when prompted. 

* Click **Begin installation**

* When the installation is complete, click Reboot System

* On first boot, run the following command to update packages
~~~
sudo dnf upgrade -y
~~~

* Reboot the VM

* Run the following command to install Git
~~~
sudo dnf install git -y
~~~

* Run the following command to clone the project repository
~~~
git clone https://github.com/nniemeir/Enterprise-Computing-I
~~~

* Navigate to the directory Scripts/Red Hat/FreeIPA Server

* Run the following command to allow the deployment scripts to be executed
~~~
chmod +x Pre-Deployment.sh Deploy.sh
~~~

* Run the script **Pre-Deployment.sh**, this will configure network settings and install some necessary packages

* After some time, the VM will reboot on its own. 

* On first login to GNOME, open the terminal 

* Navigate to the directory Scripts/Red Hat/FreeIPA Server

* Run **Deploy.sh**, this will deploy FreeIPA itself.

#### RH_Ansible

* Boot the VM from the Fedora Server 40 ISO

* Select **User Creation** and make a user

* Ensure that your locale is correct in the **Time & Date** menu

* Select **Network & Host Name**

* Select **Configure**

* Select **IPv4 Settings**

* Set **method** to manual,

* Select **add**,

* Set the following:
* **Address**: 172.16.16.3
* **Netmask**: 255.255.255.240
* **Gateway**: 172.16.16.1
* **DNS server**: 1.1.1.1.
* **Host Name**: conductor.universalnoodles.lan.

* Toggle the interface

* Click done

* Select **Installation Destination**, check **Encrypt my data** and **Free up space...** boxes

* Click **Done**

* Choose to delete all existing partitions

* Enter an encryption passphrase when prompted. 

* Click **Begin installation** 

* When the installation is complete, click **Reboot System**

* On first boot, run the following command to upgrade packages
~~~
sudo dnf upgrade -y
~~~

* Reboot the VM

* Run the following command to install Git
~~~
sudo dnf install git -y
~~~

* Run the following command to clone the project repository
~~~
git clone https://github.com/nniemeir/Enterprise-Computing-I
~~~

* Navigate to the directory Scripts/Red Hat/Ansible Server

* Run the following command to allow the deployment scripts to be executed
~~~
chmod +x Enrollment.sh Post-Enrollment.sh
~~~

* Run the script **Enrollment.sh**, this will configure network settings and install some necessary packages before it enrolls the device as a ipa-client. Reasons for installing these packages are explained (here)[preface.md].

* Run the script **Post-Enrollment.sh**, this will install Ansible and generate SSH keys for this VM. 


#### RH_DevStation
* Insert Fedora Workstation 40 ISO into RH_DevStation

* Select **Test this media** to ensure that the ISO has not been corrupted.

* When you reach the desktop, open network settings through the top right menu

* Select the settings icon on the wired interface

* Enter the **IPv4** tab

* Change **IPv4 Method** to Manual

* Set:
**Address**: 172.16.16.4
**Netmask**: 255.255.255.240
**Gateway**: 172.16.16.1

* Change DNS from automatic to 1.1.1.1

* Click **Apply**

* You should now have internet access, return to the install wizard and click **Install Fedora**

* Choose your language and continue

* Select **Installation Destination**, check **Encrypt my data** and **Free up space...** boxes

* Click done

* Choose to delete all existing partitions.

* Enter an encryption passphrase when prompted. 

* Click **Begin installation**

* When the installation is complete, click **Finish Installation**

* Type Right-Ctrl+Del, then select **Power Off**

* Reboot the VM

* On first boot, click **start setup**

* Proceed past the privacy screen

* Click **Enbable third-party repositories**, then proceed

* Assign a name to your local user

* Set a password

* Click **Start using Fedora Linux**

* Use the meta key to see your app bar, then search for **Terminal** and select it

* On first boot, run the following command to upgrade packages
~~~
sudo dnf upgrade -y
~~~

* Reboot the VM

* Open a terminal

* Run the following command to install Git
~~~
sudo dnf install git -y
~~~

* Run the following command to clone the project repository
~~~
git clone https://github.com/nniemeir/Enterprise-Computing-I
~~~

* Navigate to the directory Scripts/Red Hat/Development Workstation

* Run the following command to allow the deployment script to be executed:
~~~
chmod +x Enroll.sh
~~~

* Run **Enroll.sh**, this will enroll the device as a ipa-client.
