#!/bin/bash
#Check OS and perform updates
command -v yum > /dev/null && OS=rhel
command -v apt > /dev/null && OS=debian
snap list > /tmp/check_snap  && grep ssm /tmp/check_snap && SNAP=yes
if [ "$OS" == "rhel" ] ; then
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl status amazon-ssm-agent || sudo status amazon-ssm-agent
      sudo systemctl enable amazon-ssm-agent || sudo start amazon-ssm-agent
      sudo systemctl start amazon-ssm-agent

else
      if [ "$SNAP" == "yes" ] ; then
          echo $SNAP
          sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
          sudo systemctl stop snap.amazon-ssm-agent.amazon-ssm-agent.service
          #sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service
          sudo snap list amazon-ssm-agent
          sudo snap start amazon-ssm-agent
          sudo snap services amazon-ssm-agent
      else
          mkdir /tmp/ssm
          cd /tmp/ssm
          wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
          sudo dpkg -i amazon-ssm-agent.deb || sudo snap start amazon-ssm-agent
          sudo systemctl status amazon-ssm-agent
          sudo status amazon-ssm-agent
          sudo systemctl enable amazon-ssm-agent
          sudo start amazon-ssm-agent
        fi
fi
###############################################################
# Author: MikeZ
# Title: Installing SSM Agent via Script
# Working on the Following OS
# RHEL 6.x
# RHEL 7.6
# Rhel 8.x
# Ubuntu 16.04 and 18.04
# This script will detect the OS of your System
# Then it will install the agent
###############################################################


