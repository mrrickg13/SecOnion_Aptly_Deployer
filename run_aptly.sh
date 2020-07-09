#!/bin/bash


###################################
#				  #
#  Written By: Rick Gould         #
#  Company: Sealing Technologies  #
#  Date: May 18, 2020             #
#  Last Updated: May 27, 2020     #
#          			  #
###################################



# Install necessary software
install_packages()
{

  apt update -y && apt upgrade -y;
  sudo  dpkg --remove-architecture i386;

declare -a package_list=(aptly wget openssh-server vim mlocate git htop sshpass) 

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


###
# NEED TO ADD A .gpgnup.conf file and the settings
create_gpg_conf() {

  touch ~/.gnupg/gpg.conf;
  echo "personal-digest-preferences SHA256
        cert-digest-algo SHA256
        default-preference-list SHA256" > ~/.gnupg/gpg.conf

}


# Do two things here, one - create the key, two - create the key using ansible vars, for future use (comment out)

# Create a gpg key
set_gpg_key(){

  # This command requires user input
  gpg --gen-key;

}



send_gpg_key(){

  keyVal=$(gpg --list-keys | awk '/pub/{if (length($2) > 0) print $2}'); 
  echo "${keyVal##*/}";
  gpg --no-default-keyring -a --export ${keyVal##*/} | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import - ;
  gpg --export -a ${keyVal##*/}  > public.key;

 # This part doesnt work during boot, need to scp it over, then ***** apt-key add pubring.gpg to client
#  scp public.key localuser@10.52.51.230:~/

}


add_ubuntu_gpg() {
  echo " ADDING UBUNTU KEYS FROM KEYSERVER"
  chown root.root /home/localuser/.gnupg/
  gpg --keyserver keyserver.ubuntu.com --recv-keys 437D05B5 ;
  gpg --keyserver keyserver.ubuntu.com --recv-keys C0B21F32 ;
  gpg --keyserver keyserver.ubuntu.com --recv-keys 23F386C7 ;
  gpg --no-default-keyring -a --export 437D05B5 | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import - ;
  gpg --no-default-keyring -a --export C0B21F32 | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import - ;
  gpg --no-default-keyring -a --export 23F386C7 | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import - ;  
 # Fix permissions to remove warnings
 # find ~/.gnupg -type f -exec chmod 600 {} \
 # find ~/.gnupg -type d -exec chmod 700 {} \
}


# Get stable PPA is done in create_repo_aptly.sh script



# Create mirrors of necessary ubuntu repositories with a filter
create_mirrors() {
  echo "CREATING MIRROR"
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_main http://us.archive.ubuntu.com/ubuntu/ xenial main;
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_res http://us.archive.ubuntu.com/ubuntu/ xenial restricted;
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_uni http://us.archive.ubuntu.com/ubuntu/ xenial universe;
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_up_main http://us.archive.ubuntu.com/ubuntu/ xenial-updates main;
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_up_uni http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe; 
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_sec_main http://us.archive.ubuntu.com/ubuntu/ xenial-security main;
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_sec_uni http://us.archive.ubuntu.com/ubuntu/ xenial-security universe
  aptly mirror create -keyring="~/.gnupg/trustedkeys.gpg" -architectures="amd64" -filter=$PACKAGES -filter-with-deps mirror_so http://ppa.launchpad.net/securityonion/stable/ubuntu xenial main

}


# Downloads the packages into the mirrors. Prior to this the mirrors exist but are empty
update_mirrors(){
  echo "UPDATING MIRRORS"
  aptly mirror update mirror_main;
  aptly mirror update mirror_uni;
  aptly mirror update mirror_res;
  aptly mirror update mirror_up_main;
  aptly mirror update mirror_up_uni;
  aptly mirror update mirror_sec_main;
  aptly mirror update mirror_sec_uni;
  aptly mirror update mirror_so

}

# Create the necessary repositories
create_repos() {
  
  aptly repo create xenial_main;
  aptly repo create xenial_uni;
  aptly repo create xenial_res;
  aptly repo create xenial_up_main;
  aptly repo create xenial_up_uni;
  aptly repo create xenial_sec_main;
  aptly repo create xenial_sec_uni;
  aptly repo create xenial_so

}

import_mirrors(){
  aptly repo import mirror_main xenial_main $PACKAGES;
  aptly repo import mirror_uni xenial_uni $PACKAGES;
  aptly repo import mirror_res xenial_res $PACKAGES;
  aptly repo import mirror_up_main xenial_up_main $PACKAGES;
  aptly repo import mirror_up_uni xenial_up_uni $PACKAGES;
  aptly repo import mirror_sec_main xenial_sec_main $PACKAGES;
  aptly repo import mirror_sec_uni xenial_sec_uni $PACKAGES;
  aptly repo import mirror_so xenial_so $PACKAGES

}

# Publish the repositories
publish_repos(){

  # distribution flag can be anythign you want - it is just a name to be used in clients /etc/apt/sources.list
#  aptly publish repo -component=main,universe,restricted -distribution="xenial" xenial_main xenial_uni xenial_res xenial_up_main xenial_up uni xenial_sec_main xenial_sec_uni
  aptly publish repo -component=main,universe,restricted -distribution="xenial_main" xenial_main xenial_uni xenial_res;
  aptly publish repo -component=main,universe -distribution="xenial_updates" xenial_up_main xenial_up_uni;
  aptly publish repo -component=main,universe -distribution="xenial_security" xenial_sec_main xenial_sec_uni; 
  aptly publish repo -component=main -distribution="xenial_so" xenial_so 

}

# This will serve all publish repositories/snapshots
# Not recommended for use in production environments
#aptly_serve(){

 # aptly serve 

#}

####################################
#           As they say:           #
# This is where the magic happens. #
####################################

# Global variable of package fileter
  PACKAGES=$(cat packages.txt)
  echo $PACKAGES

install_packages
create_gpg_conf
set_gpg_key
send_gpg_key
add_ubuntu_gpg
create_mirrors
update_mirrors
create_repos
import_mirrors
publish_repos
#aptly_serve
