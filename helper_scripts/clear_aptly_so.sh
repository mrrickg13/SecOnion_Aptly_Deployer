#!/bin/bash

# RUN this to start from scratch, removes mirrors, repos and anything published

#This completely wipes out all work done by run_aptly.sh except for the gpg key


aptly publish drop xenial_main; 
aptly publish drop xenial_security;
aptly publish drop xenial_updates; 
aptly publish drop xenial_so; 
aptly repo drop xenial_main; 
aptly repo drop xenial_res;
aptly repo drop xenial_sec_main; 
aptly repo drop xenial_sec_uni; 
aptly repo drop xenial_uni; 
aptly repo drop xenial_up_uni; 
aptly repo drop xenial_so;
aptly repo drop xenial_up_main; 
aptly mirror drop mirror_main; 
aptly mirror drop mirror_res; 
aptly mirror drop mirror_sec_main; 
aptly mirror drop mirror_sec_uni; 
aptly mirror drop mirror_uni; 
aptly mirror drop mirror_up_uni; 
aptly mirror drop mirror_so; 
aptly mirror drop mirror_up_main;
rm -rf /home/localuser/.aptly/db/;
rm -rf /home/localuser/.aptly/public/;
rm -rf /home/localuser/.aptly/pool/

