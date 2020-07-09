# SecOnion-deployer
Welcome to the Security Onion Deployer. This documentation will provides instructions on how to deploy Security Onion to physical node within a diconnected CURE environment. As a note, Security Onion will be installed on an Ubuntu 16.04 operating system.


## BIOS Settings
To begin, there are BIOS settings that need to be set on the physical node that will be used for Security Onion. If you can't get into the BIOS directly, make sure there is a BMC IP set, and enter via a KVM.
- Ensure Legacy boot is enabled
- Disable secure boot
- Ensure Virtualization is enabled
- The disk the operating system will be installed to can be set as the primary boot

## Default username/pwd 
By default there is no root user created in Ubuntu, this gives the 'lolcaluser' sudo priviledes. The 'localuser' credentials are built into the preseed file prior to boot. It is recommened to create a new user with sudo priveledges, or change the password once the Security Onion installation process is complete.

username: localuser
password: 12345678

## Settings to change! Important
This installation has been designed for a disconnected build. Therefore it needs a local repository to use to grab all of the required security updates and Security Onion packages. For this deployment, that repository has been pre-built and loaded into the environment.  

In particular repo_IP must be changed to the internal repository hosting the Ubuntu and Security Onion content.
 

## Let's Begin! 

## Set up the Repository

The repository should be a virtual machine QCOW.  Recommended practice would be to regularly update this image and then disctribute these to the kits at time of provisioning. After the repository script has ran, it will also have been STIG'd. Install a standard Ubuntu 16.04 VM and then run he following scripts

The VM used as the repository must be an Ubuntu 16.04 installation with minimum 250GiB of storage. If you have ran the script multiple times and find you have run out of space on the repository node, you can run the clean.sh script located in /var/spool/apt-mirror/var/ to free up space.  

1) Move so-stig-sealing directory and create_repo.sh to the box to be used as the local repository. Be sure they live in the home (~/) directory.

A script (create_repo.sh) has been written to automatically set up a node to act as the offline repository. This script will download all necessary packages and docker images required for Security Onion. On an Ubuntu 16.04 Xenial node, scp create_repo.sh script and run it. If it is the first time running the script, it will take approximately 1.5hrs to complete. Any subsequent runs (for patches for example) will take only a matter of minutes. 

Ensure the node has internet access before the script is run.   

2) This Virtual Machine must be moved to the kit and properly networked.


## Deploy Security Onion 

1) Configure the variables to work within your specific environment which can including desired naming conventions for Securty Onion related materials. The variable file can be found in ./group_vars/SecOnion_vars.yml. Further detail on each variable is explained in that file. 

2) Check the 'inven' (or inventory) file. Make sure the IP of the repository is set (repo_IP variable)

3) Run the hammer playbook. This will set all of the configuration pieces Satellite requires to provision the node. You must call CURE's inventory file
	$ ansible-playbook -i /opt/cure/ansible_main/inven  hammer_playbook.yml

4) Log into a KVM via IPMI, click F12 to trigger a network boot. Satellite will present an option for Foreman Discovery. Choose this option and wait for it to complete. When it is finished, it will present the MAC and IP of the bare metal node. 

5) Next log into Satellite and choose Hosts -> Host Discovery. The newly discovered node will be listed, it's name is its MAC address. Click on 'Provision' on the right hand side then select Security Onion from the drop down. Select 'Create Host'

6) The node will reboot, during this time ensure it PXEBoot's, by clicking F12. During this iteration, it will boot via the preseed configuration, using the previsouly created repository to get the packages and software. 

7) Once you log into the box, check on the status of the elastic.service as well as the stig.service. They are custom systemd services that run on boot (only the initial boot) and should be completed before moving onto the next step. If the output shows 'Inactive (dead)' without errors, the services have completed and you can move on to step 9.  
 $ systemctl status elastic.service  
 $ systemctl status stig.service  

Note: To take complete effect, the node needs to be rebooted after the stig.service runs. If you skip the step in the Security Onion configuration which requires a reboot, you will need to reboot the machine on your own.  Please reset the password immediately 

9) Update the software:  
 $ sudo apt update && apt upgrade -y

10) Once it it complete, Ubuntu and Security Onion is installed, it's time to go through the Securty Onion Wizard to finish the set up. The Wizard can be found on the desktop of the UI. 


### Preseed.cfg File
The preseed.cfg file is the main boot conifugration file that the system uses for its configurations during the boot process. A full file with all possible options is located within the documents folder called ubuntu_preseed.txt. For this install, the preseed.cfg file that is used is stripped of unecessary or unused configuration options. 


### Post install
Run the Security Onion wizard, found on the desktop. See Security Onion installation documentation for details. 


### Updating Packages and Security Patches
Ensure the repository has internet access, and run the create_repo.sh script again. Once that is complete, run this command on the Security Onion node:  
$ apt update && apt upgrade -y    

## To Redeploy a host
In order to redeploy a system you must first remove it from Satellite.

- Select Hosts > All hosts 
- Find the host you want to redeploy and select the drop down arrow and 'Delete' 



## To Redeploy all configurations
If for some reason you need to re configure Satellite and redeploy 

- Select Configure > Host Group and delete the Security_Onion Host group
- Delete installation media, OS, and the partition table
- Select Hosts > Operating System and delete Security Onion 16.4
- Select Hosts > Installation Media Security_Onion_PXE
- Select Hosts > Partition Tables  The preseed default assigned to the Security Onion 16.4 partition table


