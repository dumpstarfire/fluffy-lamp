#!/bin/bash
#Check OS and perform updates
command -v yum > /dev/null && OS=rhel
command -v apt > /dev/null && OS=debian
sw_vers > /dev/null && OS=osx

echo $OS
if [ "$OS" == "rhel" ] ; then
     curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
     sudo yum install -y session-manager-plugin.rpm
elif [ "$OS" == "debian" ] ; then
     curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
     sudo dpkg -i session-manager-plugin.deb
elif [ "$OS" == "osx" ] ; then
     curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
     unzip sessionmanager-bundle.zip
     sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
else
     echo "canno install"
fi
session-manager-plugin
