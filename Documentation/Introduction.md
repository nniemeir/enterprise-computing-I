## Preface
This repository contains a revised version of an academic project done by myself in 2022. The goal of the project was to develop a greater understanding of how network/system administration is done on small domains and what similarities and differences exist between how enterprise networks built around the Microsoft and Red Hat ecosystems are managed.

The project was done in six stages:

1. Creation - Virtual machines were created representing two networks.

* In the first network:
    * RH_pfSense
        * pfSense 23.05.1
        * Network-based firewall
    * RH_FreeIPA
        * Fedora Server 39
        * Domain Controller
    * RH_Ansible
        * Fedora Server 39
        * Ansible automation
    * RH_DevStation
        * Fedora Workstation 39
        * Domain member

* In the second network:
    * MS_pfSense
        * pfSense 23.05.1
        * Network-based firewall
    * MS_Server
        * Windows Server 2022
        * Domain Controller
    * MS_DevStation
        * Windows 11
        * Domain member
     
*Though many business networks contain file servers and databases, these were not included due to the time allotted for the project.*
<br/>

2. Extension - PowerShell scripts and Ansible playbooks were written to deploy a working environment to the development workstations on the Microsoft and Red Hat networks respectively. 

3. Hardening - Ensured that none of the virtual machines had been compromised during initial setup, then took basic hardening measures based on recommendations from the software vendors and the third edition of Chuck Easttom's book *Network Defence and Countermeasures*. Due to the extensive hardening advice from the software vendors alone and the limited time alotted to the project, there are many areas where security could be further improved.

4. Testing - The success of the deployment was tested using the criteria defined [here](Testing.md). Next, Nessus was ran and problematic configurations were changed based on the results. Lastly, testing was done again to ensure that changes did not break anything. 

5. Reproducibility - Deployment scripts were written and steps that were not feasible to automate were documented.

6. Reporting & Demonstration - project documentation was completed and advisor was given remote access to the virtual machines.

## Rationale
* pfSense was chosen as the network-based firewall for both subnets due to it being the most popular FOSS firewall

* Fedora Linux was used due to it being upstream of Red Hat Enterprise Linux, which made it a prime candidate for exploring enterprise software without investing in licenses. As with RHEL, Fedora ships the Mandatory Access Control security architecture SELinux preconfigured.

* Microsoft Windows was used as it is by far the most popular desktop operating system and Windows Server is the most popular enterprise operating system, so being familiar with both is essential for IT professionals.

* The applications deployed to the developer workstations are by no means representative of a complete development toolkit and rather demonstrate a possible usage of Ansible and Windows Remote Management in an enterprise environment. 


