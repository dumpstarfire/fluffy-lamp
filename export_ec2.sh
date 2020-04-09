#!/bin/bash
#Step 1: Check for Instance ID
if [ -z "$1"] ; then
     echo "Nothing was entered"
     read -p  "Please enter Intance ID: " INSTANCE_ID
else
     INSTANCE_ID=$1
fi
S3_EXP_Bucket=$INSTANCE_ID-export
# Step 2: Locate Instance region
for region in `aws ec2 describe-regions --output text | cut -f3`
do
     aws ec2 describe-instances --region $region | grep $INSTANCE_ID && REGION_IN=$region
done
# Step 3: Create an S3 Bucket to export the Instance
aws s3api create-bucket --bucket $S3_EXP_Bucket --region $REGION_IN --create-bucket-configuration LocationConstraint=$REGION_IN
#Step 4: Create json file
sudo cat > export.json << EOF
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "$S3_EXP_Bucket",
    "S3Prefix": "vms/"
}
EOF
# Step 5 - Add permissions for import/export
aws s3api put-bucket-acl --bucket $S3_EXP_Bucket --grant-read-acp id=c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322 --grant-write id=c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322
#Step 6: Export Instance AWS/cli
aws ec2 create-instance-export-task --instance-id $INSTANCE_ID --target-environment vmware --export-to-s3-task file://export.json --region $REGION_IN

###############################################################
# Author: MikeZ @dumpstarfire
# Title: Export EC2 to S3 Bucket
# Email: dumpstarfire@gmail.com
###############################################################
