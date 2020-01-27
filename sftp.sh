#!/bin/bash
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
sed 's/anonymous_enable=YES/anonymous_enable=YES/g' /etc/vsftpd/vsftpd.conf
echo "chroot_local_user=YES" >> /etc/vsftpd/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=Yes" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=40000" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=40100" >> /etc/vsftpd/vsftpd.conf

groupadd sftp_users

if [ "$OS" == "rhel" ] ; then
     adduser $1
     echo $2 | passwd $1 --stdin

else
     adduser --disabled-password --gecos "" $1
     echo $1:$2 | chpasswd

fi

mkdir -p /data
chmod 701 /data

mkdir -p /data/$1/upload
chown -R root:sftp_users /data/$1
chown -R $1:sftp_users /data/$1/upload

echo "Match Group sftp_users" >> /etc/ssh/sshd_config
echo "ChrootDirectory /data/%u" >> /etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

sed -i 's/PasswordAuthentication\s*no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

read -p  "Do you want to allow root to login? y/n: " root_answer
if [ "$root_answer" == "y" ] ; then
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    read -p "Setting root password: " root_password
    if [ "$OS" == "rhel" ] ; then
         echo $root_password | passwd root --stdin
    else
         echo root:$root_password | chpasswd
    fi
else
    echo "Password Not Chosen"
fi
systemctl restart sshd
systemctl restart vsftpd

read -p  "Do you want to create a user? y/n: " user_answer
if [ "$user_answer" == "y" ] ; then
    read -p "Enter username: " user_name
    useradd $user_name
    read -p "Setting user password: " user_password
    if [ "$OS" == "rhel" ] ; then
          echo $user_password | passwd $user_name --stdin
    else
          echo $user_name:$user_password | chpasswd
    fi
else
    echo "Password Not Chosen"
fi

