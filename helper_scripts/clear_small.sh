#!/bin/bash

# RUN this to start from scratch, removes mirrors, repos and anything published

#This completely wipes out all work done by run_aptly.sh except for the gpg key


aptly publish drop xenial_so; 
aptly repo drop xenial_so;
aptly mirror drop mirror_so; 

