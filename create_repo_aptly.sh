#!/bin/bash

###################################
#				  #
#  Written By: Rick Gould         #
#  Company: Sealing Technologies  #
#  Date: April 15, 2020           #
#  Last Updated: April 22, 2020   #
#          			  #
###################################


# Run this script as sudo to set up the 
#  Security Onion Repository for offline
#  installation of Security Onion on a
#  bare metal node.
# 
# **** Minimum 250GiB of storage is required **** 


# Install necessary software
install_packages()
{
declare -a package_list=(wget openssh-server vim apt-mirror apache2 mlocate git docker docker.io aptly)

for i in "${package_list[@]}"; do

PKG_CHECK=$(dpkg -s $i 2> /dev/null | grep 'install ok installed' > /dev/null ; echo "$?")

if [ "$PKG_CHECK" == 1 ] ; then
    echo -e "\e[32mInstalling $i.\e[0m"
    apt install $i -y
else
    echo -e "\e[34m$i package already installed.\e[0m"
fi;
done
}

# Grab docker airgap repository while still online
# Docker airgap details here: 
#  https://securityonion.readthedocs.io/en/latest/docker.html
docker_airgap_clone(){

FOLDER="securityonion-docker-airgap"
URL="https://github.com/weslambert/securityonion-docker-airgap"

#if [ ! -d "$FOLDER" ] ; then
    # Remove existing folder to ensure latest updates are pulled
    rm -rf $FOLDER;
    echo -e "\e[34mCloning the Security Onion docker airgap repository\e[0m"
    git clone $URL;
#else
 #  echo -e "\e[34mClone failed because the folder ${folder} already exists.\e[0m"
#fi
}

# Run the so-elastic-airgap script to pull the docker airgap images
docker_airgap_pull(){
    echo -e "\e[34m Pulling latest docker images\e[0m"
    cd securityonion-docker-airgap
    echo "1" | ./so-elastic-airgap;
}

# Place the tar file where the preseed configuration can grab it
move_so-stig-sealing(){

DIR=/var/www/html
FILE=so-stig-sealing.tar.gz
   
    cd ~/SecOnion_Aptly_Deployer/ 
    tar -czf $DIR/$FILE so-stig-sealing
    chmod 644 $DIR/$FILE;

}

# Tar docker images
docker_image_tar(){

DIR=/var/www/html/
FILE=docker-airgap.tar.gz

  echo -e "\e[34mMovign docker tar file to web server directory\e[0m"
  cd ~/SecOnion_Aptly_Deployer/
  tar -czf $FILE securityonion-docker-airgap;
  mv $FILE $DIR;

}

# Add Security Onion repository
seconion_repo(){
    echo -e "\e[34mPulling stable SO repository\e[0m"
    echo -ne "\n" | add-apt-repository ppa:securityonion/stable;
}

# Create template used to build systemd service on offline node
elastic_service(){

FILE=elastic.service

if test -f "/var/www/html/$FILE"; then
    echo -e "\e[34mFile $FILE already exists, skipping\e[0m"
else
    echo "[Unit]
Description=Elastic airgap service

[Service]
Type=oneshot
ExecStart=/usr/sbin/airgap.sh

[Install]
WantedBy=multi-user.target" >> /var/www/html/$FILE;

# Make it and available
chmod 644 /var/www/html/$FILE;

fi


}

# Create template used to build script called by elastic.service
airgap_script(){

FILE=airgap.sh

if test -f "/var/www/html/$FILE"; then
    echo -e "\e[34mFile $FILE already exists, skipping\e[0m"
else
echo "#!/bin/bash

cd /securityonion-docker-airgap;

echo "2" | /bin/bash -c "/securityonion-docker-airgap/so-elastic-airgap";" >> /var/www/html/$FILE;

# Make it executable and available
chmod +x /var/www/html/$FILE;
chmod 644 /var/www/html/$FILE;

fi


}

# Create template used to build systemd service on offline node
stig_service(){

FILE=stig.service

if test -f "/var/www/html/$FILE"; then
    echo -e "\e[34mFile $FILE already exists, skipping\e[0m"
else
    echo "[Unit]
Description=STIG Remediation service

[Service]
Type=oneshot
ExecStart=/usr/sbin/stig.sh

[Install]
WantedBy=multi-user.target" >> /var/www/html/$FILE;

# Make it and available
chmod 644 /var/www/html/$FILE;

fi


}

# Create template used to build script called by stig.service
stig_script(){

FILE=stig.sh

if test -f "/var/www/html/$FILE"; then
    echo -e "\e[34mFile $FILE already exists, skipping\e[0m"
else
echo "#!/bin/bash

cd /so-stig-sealing;

echo "Y" | /bin/bash -c "./so-stig-sealing";" >> /var/www/html/$FILE;

# Make it executable and available
chmod +x /var/www/html/$FILE;
chown 644 /var/www/html/$FILE;

fi


}
# Create script to be ran on SO node at boot
config_script(){


#### move pubring.gpg to /home/localuser, the add apt-key add command here


# Grab IP of host machine
HOST_IP="$(ip route get 1 | awk '{print $NF;exit}')";

echo "!#/bin/bash

# This script is called by the preseed to ensure the new node is configured
# to be able to install Security Onion

echo "debconf debconf/frontend select noninteractive" | sudo debconf-set-selections;

dpkg --remove-architecture i386;

apt purge libappstream3 -y;

#sources.list file on new node/vm

rm -f /etc/apt/sources.list;
touch /etc/apt/sources.list;

echo "deb http://$HOST_IP:8080/ xenial_main main restricted universe" >> /etc/apt/sources.list;

echo "deb http://$HOST_IP:8080/ xenial_updates main universe" >> /etc/apt/sources.list;
echo "deb http://$HOST_IP:8080/ xenial_security main universe" >> /etc/apt/sources.list;
echo "deb [trusted=yes] http://$HOST_IP:8080/ xenial_so main" >> /etc/apt/sources.list;

apt-get update --allow-insecure-repositories;

apt install -y software-properties-common syslog-ng-core securityonion-all securityonion-onionsalt;

keyVal=$(gpg --list-keys | awk '/pub/{if (length($2) > 0) print $2}'); 
  echo "${keyVal##*/}";
  gpg --no-default-keyring -a --export ${keyVal##*/} | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import - ;
  gpg --export -a ${keyVal##*/}  > public.key;
  
  #scp public.key localuser@$HOST_IP:~/
  
  #cp /home/localuser/.gnupg/pubring.gpg /var/www/html/;
  #scp localuser@$HOST_IP:~/pubring.gpg .;
  wget http://@HOST_IP:/pubring.gpg -P .;
  apt-key add pubring.gpg;
" >> so_config.sh

mv so_config.sh /var/www/html;

}

# Create sym link used by the node to pull from the offline repository
#sym_link(){

# New version uses aptly, which serves the repos on localhost:8080


#ln -s /var/spool/apt-mirror/mirror/archive.ubuntu.com/ubuntu/ /var/www/html/ubuntu;
#ln -s /var/spool/apt-mirror/mirror/ppa.launchpad.net/securityonion/stable/ubuntu/ /var/www/html/securityonion;

#}


# Run aptly script to create repo.
aptly() {

  ./run_aptly.sh
}

# Export the SO key so the node can update and move pubring so node can grab it
export_key(){

  cp /home/localuser/.gnupg/pubring.gpg /var/www/html/
  apt-key export > securityonion.key;
  mv securityonion.key /var/www/html/;

}

# Run update after all is said and done
apt_update(){

  # K.I.S.S
  apt update -y && apt upgrade -y;
}

# Run the stig script on the repository and reboot
stig_repo(){
# aptly serve should be ran on boot by systemd, keeping reboot here
  cd ~/SecOnion_Aptly_Deployer/so-stig-sealing/;
  echo "Y" | /bin/bash -c "~/SecOnion_Aptly_Deployer/so-stig-sealing/so-stig-sealing";

  mv ~/SecOnion_Aptly_Deployer/files/aptly_serve.sh /etc/init.d/;
  chmod +x /etc/init.d/aptly_serve.sh;
  #echo "aptly serve" > aptly_serve.sh;
  #cp aptly_serve.sh /etc/init.d/;
  sed -i -e 's/.*exit.*/aptly_serve.sh\n&/' /etc/rc.local;
#aptly serve;

  reboot;
}

####################################
#           As they say:           #
# This is where the magic happens. #
####################################
check_www_connection(){
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    echo -e "\e[34mRunning functions that require internet connection\e[0m"
    install_packages
    docker_airgap_clone
    docker_airgap_pull
    seconion_repo
    #apt_mirror
    return 0 
else
    echo -e "\e[34mNo internet connection available, skipping package install, docker and SO repository pull, and apt-mirror creation/update.\e[0m"
fi
}
check_www_connection
move_so-stig-sealing
docker_image_tar
elastic_service
airgap_script
stig_service
stig_script
config_script
sym_link
#mirror_list
aptly
export_key
apt_update
stig_repo
