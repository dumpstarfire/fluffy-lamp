#!/bin/bash
#Check OS and perform updates
command -v yum > /dev/null && OS=rhel
command -v apt > /dev/null && OS=debian
if [ "$OS" == "rhel" ] ; then
     yum -y update
     yum -y install vsftpd
     yum -y install openssh-server
else
     apt-get -y update
     apt-get -y install vsftpd
     apt-get -y openssh-server
fi

# Edit SFTP configuration file
sed 's/anonymous_enable=YES/anonymous_enable=YES/g' /etc/vsftpd/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=Yes" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=40000" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=40100" >> /etc/vsftpd/vsftpd.conf

#Create sftp_users group

groupadd sftp_users

#Create SFTP directory
mkdir -p /data
chmod 701 /data

#Add users added from bash


if [ "$OS" == "rhel" ] ; then
     adduser $1
     echo $2 | passwd $1 --stdin

else
     adduser --disabled-password --gecos "" $1
     echo $1:$2 | chpasswd

fi

mkdir -p /data/$1/upload
chown -R root:sftp_users /data/$1
chown -R $1:sftp_users /data/$1/upload

#Add users from /home to data access on sshd_config file

echo "Match Group sftp_users" >> /etc/ssh/sshd_config
echo "ChrootDirectory /data/%u" >> /etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

sed -i 's/PasswordAuthentication\s*no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

#Restart Services

systemctl restart sshd
systemctl restart vsftpd



###############################################################
# Author: MikeZ
# Title: Install & Configure SFTP
# Working on the following OS'#!/bin/sh
# Amazon Linux 2 - Root and User Works
# Amazon Linux 1 - You will need to restart services or reboot system
#                 You would need to fix uuid for root login
# RHEL 8    - Root and User works
# Ubuntu 18 - Root and User works
# Centos 8  - Root and User works
# This script will detect the OS of your System
# Then it will download the appropriate packages
# After downloading the nescessary packages it will then
# edit the appropriate files
# After so if you want to enble root for SFTP or create users,
# You can do so after installing
###############################################################
