
Additional Information to add in as part of RMF work.

•	Repository/Registry section needs to be rebuilt, using aptly instead of apt-mirror
•	Add Table of Contents

## Armory Instructions
•	see README

STIGS have not been applied to Forward and Storage nodes

## Distributed Deployment
The distributed deployment consists of a minimum three nodes. There is the ability to add aditional Forward and Storage nodes, however that is not covered in this guide. 


**NOTE** a known username and password to a user on the Master node with ssh and sudo priveleges must be present for the Storage and Forward nodes to connect. 

The first node to set up is considered the Master node. It's installation is nearly identical to the Standalone node deployment.



####Key differences:
<ol>
<li>Do not configure sniffing interfaces</li>
<li>Disable Network sensor services, that will be the job of the Forward Node</li>
<li>Store the logs on a dedicated Storage node and not on the master</li>
</ol>








With the Distributed deployment strategy,the Master sits on bare metal, while the support nodes live on virtual machines. 

It is important to spin up and configure the Master node first. This node needs to be updated and configured before attaching any supporting nodes. 

There are three ways to run through the Security Onion configuration. The setup wizard, the setup TUI, or running a pre-configured configuration file. The most common way is the setup wizard. 

###Setup Wizard
Follow the steps below to install the Security Onion Master Node using the setup wizard.


<center>
<img src="images/1 SO Setup Icon.png" width="300" height=200/ style="text-align:center">
</center>
<center>Navigate to the Desktop and double click the Setup icon</center>

<center>
<img src="images/2 SO Welcome.png" width="300" height=200/ style="text-align:center">
</center>
<center>A welcome screen will appear</center>

<center>
<img src="images/3 SO Configure Int.png" width="400" height=200/ style="text-align:center">
</center>
<center>During the initial setup, choose to configure the network interfaces</center>

<center>
<img src="images/4 SO Choose Mgmt Int.png" width="300" height=200/ style="text-align:center">
</center>
<center>Select which interface should be the management interface</center>

<center>
<img src="images/5 SO Choose DHCP.png" width="300" height=200/ style="text-align:center">
</center>
<center>For this deployment, choose DHCP, however setting static network information is an option</center>

<center>
<img src="images/6 SO Choose Sniffing.png" width="350" height=200/ style="text-align:center">
</center>
<center>This is a Distributed deployment, so do **not** configure sniffing interfaces here. That will be the job of the Forward node</center>


<center>
<img src="images/8 SO Net Changes.png" width="300" height=200/ style="text-align:center">
</center>
<center>Accept the prompt to make Network changes. At this point the wizard will ask to reboot, click Yes</center>

<center>
<img src="images/9 SO Production Mode.png" width="400" height=300/ style="text-align:center">
</center>
<center>Once the box reboots, log back in and click on the Setup icon again. Skip Network configuration this time. It will then prompt to choose between Evaluation and Production mode. Choose Production mode</center>

<center>
<img src="images/10 So New if Master.png" width="300" height=200/ style="text-align:center">
</center>
<center>Select New. For configuring a Distributed deployment, the Master node gets created first, then following nodes will select 'Existing' and be brought in. Further information in sections covering the setup of the Forward and Storage nodes. </center>

<center>
<img src="images/11 SO Create User.png" width="300" height=200/ style="text-align:center">
</center>
<center>Enter a name for the Security Onion user</center>

<center>
<img src="images/12 SO Set Pwd.png" width="300" height=200/ style="text-align:center">
</center>
<center>Set the users password</center>

<center>
<img src="images/13 SO Best Practies.png" width="300" height=200/ style="text-align:center">
</center>
<center>Choose Best Practices</center>

<center>
<img src="images/14 SO Emrg Threats IDS Rules.png" width="350" height=250/ style="text-align:center">
</center>
<center>This deployment does not supply and licences that require purchases, leave the default selection and click OK</center>

<center>
<img src="images/15 SO Snort.png" width="300" height=200/ style="text-align:center">
</center>
<center>Choose either Snort or Suricata. This documentation covers Snort</center>

<center>
<img src="images/16D SO Enable for Distributed.png" width="350" height=200/ style="text-align:center">
</center>
<center>This is a Distributed deployment, so choose the option to Disable Network Services</center>


<center>
<img src="images/21 SO Yes Make Changes.png" width="300" height=200/ style="text-align:center">
</center>
<center>Yes! Proceed with changes</center>

<center>
<img src="images/Final Service Icons.png" width="300" height=200/ style="text-align:center">
</center>

<center>Once the installation is complete, these services will be available on the Desktop</center>


Follow the steps below to set up the **Storage** Node

**NOTE** this guide should probably talk about how to install the VM, what resources it needs, etc, as well as give the commands to install packages required for SO

<center>
<img src="images/1 SO Setup Icon.png" width="300" height=200/ style="text-align:center">
</center>
<center>Navigate to the Desktop and double click the Setup icon</center>

<center>
<img src="images/2 SO Welcome.png" width="300" height=200/ style="text-align:center">
</center>
<center>A welcome screen will appear</center>

<center>
<img src="images/3 SO Configure Int.png" width="400" height=200/ style="text-align:center">
</center>
<center>During the initial setup, choose to configure the network interfaces</center>

<center>
<img src="images/4D SO Storage Management Interface.png" width="300" height=200/ style="text-align:center">
</center>
<center>This example shows a VM with only one network interface, so SO chooses it as the default</center>

<center>
<img src="images/5 SO Choose DHCP.png" width="300" height=200/ style="text-align:center">
</center>
<center>For this deployment, choose DHCP, however setting static network information is an option</center>

<center>
<img src="images/6D SO Storage DHCP.png" width="350" height=200/ style="text-align:center">
</center>
<center>This is a Distributed deployment, so do **not** configure sniffing interfaces here. That will be the job of the Forward node</center>


<center>
<img src="images/8 SO Net Changes.png" width="300" height=200/ style="text-align:center">
</center>
<center>Accept the prompt to make Network changes. At this point the wizard will ask to reboot, click Yes</center>

<center>
<img src="images/9 SO Production Mode.png" width="400" height=300/ style="text-align:center">
</center>
<center>Once the box reboots, log back in and click on the Setup icon again. Skip Network configuration this time. It will then prompt to choose between Evaluation and Production mode. Choose Production mode</center>

<center>
<img src="images/10 So New if Master.png" width="300" height=200/ style="text-align:center">
</center>
<center>Select New. For configuring a Distributed deployment, the Master node gets created first, then following nodes will select 'Existing' and be brought in. Further information in sections covering the setup of the Forward and Storage nodes. </center>

<center>
<img src="images/11 SO Create User.png" width="300" height=200/ style="text-align:center">
</center>
<center>Enter a name for the Security Onion user</center>

<center>
<img src="images/12 SO Set Pwd.png" width="300" height=200/ style="text-align:center">
</center>
<center>Set the users password</center>

<center>
<img src="images/13 SO Best Practies.png" width="300" height=200/ style="text-align:center">
</center>
<center>Choose Best Practices</center>

<center>
<img src="images/14 SO Emrg Threats IDS Rules.png" width="350" height=250/ style="text-align:center">
</center>
<center>This deployment does not supply and licences that require purchases, leave the default selection and click OK</center>

<center>
<img src="images/15 SO Snort.png" width="300" height=200/ style="text-align:center">
</center>
<center>Choose either Snort or Suricata. This documentation covers Snort</center>

<center>
<img src="images/16D SO Enable for Distributed.png" width="350" height=200/ style="text-align:center">
</center>
<center>This is a Distributed deployment, so choose the option to Disable Network Services</center>


<center>
<img src="images/21 SO Yes Make Changes.png" width="300" height=200/ style="text-align:center">
</center>
<center>Yes! Proceed with changes</center>

<center>
<img src="images/Final Service Icons.png" width="300" height=200/ style="text-align:center">
</center>

<center>Once the installation is complete, these services will be available on the Desktop</center>


### TUI 

Run this command from the shell that will open a TUI:

$ sosetup

### Configuration File
Or copy the configuration file into the home directory, edit the file with the system settings, then run the setup. Steps as follows:

$ cp /usr/share/securityonion/sosetup.conf     ~/

Edit the file and run:

$ sosetup  -f  ~/sosetup.conf 

## Check Installation Status

After the setup is complete, check on the status of the services using the command: 

$ so-status

This will give you a quick view of all running services. For a more in-depth look, use: 

$ sostat

Note – Kibana may take some time to start, if it is in a ‘Warn’ state, wait a few minutes and check again.

To restart all services:

$ so-restart



## Users

It is important to note that the users that are created for Security Onion are completely separate then the users used by the Operating System. Think of them as different entities. You cannot log into Security Onion using OS level users and vice versa. 

During the initial setup and configuration, the user will be prompted to create a user and password. Security Onion implements apache2 Single Sign On (SSO). After setup is complete, the user can be used to log into the Kibana dashboard as well as the Sguil analyst console. The user credentials are stored in the on-board MySQL database. 

The initial user, as well as any users created following setup, are all considered ‘admin’ users. Out of the box there is no way to change the user’s permissions, that functionality requires a third-party license purchase. Because of this, it is important to note that some functionality may not be standard or expected. Should a user log into Kibana and modify the dashboard, the change is system wide. It is not tied to that user. Effectively all users are sharing one dashboard. 

For auditing purposes, each user’s login and logout time is logged. Additionally, any failed login attempts are also logged. Creating users or changing user passwords does not get logged. 

To create a new user, use the built-in command: 

$ so-user-add

To update a user password use:

$ so-user-passwd

To see a list of users:

$ so-user-list

To disable a user:

$ so-user-disable

## Tuning
•	Default Kibana dashboards
•	Sguild dashboard
•	Using the so-pcap-import command to start piping in pcap data from network tap

## Updating
In order to update the software packages and docker images on the Security Onion node, the repository must first be updated. Log into the repository, ensure it has internet access run:

$ sudo apt update -y 

That will download the latest software packages. To download the latest docker images, there is a pre-packaged SO script to run: 

$ ./so-elastic-airgap

Choose ‘Save’. The output will be a directory called securityonion-docker-airgap which will include a tar file of the images. Copy the entire directory to the Security Onion node:

$ scp -r securityonion-docker-airgap localuser@xx.xx.xx.xx:~/

That concludes the work that needs to be done on the repository. Next log into the Security Onion node and change directory into securityonion-docker-airgap:

$ cd securityonion-docker-airgap/

Run the script again but this time choose ‘Load’, this will update the docker images on the Security Onion node:

$ ./so-elastic-airgap

Finally, run the update command to update the OS software:

$ sudo apt update -y


## Pre-Degaussing

Prior to Degaussing the equipment, the end user may want to offload some files for long term storage. The following instructions are meant to be suggestions only. 

Retrieving all data from all databases on the node will be the most thorough method, however if the end user chooses the MySQL data retrieval can be broken into individual databases. 

To grab all data from all databases on the node:

$ mysqldump --defaults-file=/etc/mysql/debian.cnf --all-databases > dump.sql


The end user may also want log files off of the node prior to destruction. Logs are stored in the /var/log/ directory. 

The end user may want to save configuration files. Configuration files are store in the /etc/nsm/ directory. 



## Repair

During the installation, if any services fails to start you can simply re-run the setup and re-install to repair the system. 





