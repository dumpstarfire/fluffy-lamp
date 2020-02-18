#!/bin/bash
#Check OS and perform updates
command -v yum > /dev/null && OS=rhel
command -v apt > /dev/null && OS=debian
sw_vers > /dev/null && OS=osx
command -v unzip > /dev/null && ZIP=yes

if [ "$ZIP" != "yes" ] ;
then
    echo "unzip installed"
    if [ "$OS" == "rhel" ] ; then
         sudo yum install unzip -y
    elif [ "$OS" == "debian" ] ; then
         sudo apt-get install unzip -y
    elif [ "$OS" == "osx" ] ; then
         echo "OSX unzip install unsupported"
    else
         echo "cannot install, please try installing manually"
    fi
else
    echo "Unzip Installed"
fi

if [ "$OS" == "rhel" ] ; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
elif [ "$OS" == "debian" ] ; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
elif [ "$OS" == "osx" ] ; then
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
else
     echo "cannot install"
fi


###############################################################
# Author: MikeZ @dumpstarfire
# Title: Install & Configure awscli
# Working on the following OS's
# MAC OSX
# RHEL Based
# Ubuntu Based
# Script will do the Following
#1. Check if unzip is installed. If not, on a linux machine
#    it will install unzip. NOTE: will not install on OSX
#2. Install awscli based on the Operating System
###############################################################
