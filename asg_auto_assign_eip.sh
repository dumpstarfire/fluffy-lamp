#!/bin/bash

# configure AWS if you are not using instsance profile
#aws configure set aws_access_key_id {MY_ACCESS_KEY}
#aws configure set aws_secret_access_key {MY_SECRET_KEY}
#aws configure set region {MY_REGION}

# associate Elastic IP
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
echo $REGION
aws ec2 describe-addresses  --query 'Addresses[?AssociationId==null]' --region $REGION | grep -o 'eipalloc-.*' > /tmp/eip.txt
grep -o 'eipalloc-.*' /tmp/eip.txt | sed 's/.\{3\}$//' >> /tmp/eipf.txt
line=$(head -n 1 /tmp/eip.txt)
ALLOCATION_ID=$(head -n 1 /tmp/eipf.txt)
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID --allow-reassociation --region $REGION
###########################################################
# Author: @dumpstarfire
# Title: Attach Available EIP automatically to instance
# This script grab a list of available EIP's
# Then it will grab the EIP and attach it to the Instance
###########################################################
