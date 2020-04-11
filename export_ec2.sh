#!/bin/bash
echo "Step 1: Check if Instance ID was passed if not ask for one"
[[ $1 ]] && INSTANCE_ID=$1 || read -p "`echo -e '\nNothing was entered.\nPlease Enter an Instance: '`" INSTANCE_ID
S3_EXP_Bucket=$INSTANCE_ID-export
EXP_ID=export-$INSTANCE_ID

echo "Step 2: Locate Instance region"
for region in `aws ec2 describe-regions --output text | cut -f3`
do
     aws ec2 describe-instances --region $region | grep $INSTANCE_ID && REGION_IN=$region
done

echo "Step 3: Create an S3 Bucket to export the Instance"
aws s3api create-bucket --bucket $S3_EXP_Bucket --region $REGION_IN --create-bucket-configuration LocationConstraint=$REGION_IN

echo "Step 4: Create json file"
sudo cat > export.json << EOF
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "$S3_EXP_Bucket",
    "S3Prefix": "vms/"
}
EOF

echo "Step 5 - Add permissions for import/export"
aws s3api put-bucket-acl --bucket $S3_EXP_Bucket --grant-read-acp id=c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322 --grant-write id=c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322

echo "Step 6: Export Instance AWS via AWS cli"
EXP_ID=`aws ec2 create-instance-export-task --instance-id $INSTANCE_ID --target-environment vmware --export-to-s3-task file://export.json --region $REGION_IN --output text | head -n1 | awk '{print $2}' `

echo "Step 7 - Run a for loop until the export is completed"
status=active
until [ $status == completed ]
do
  echo "testing for active"
  status=`aws ec2 describe-export-tasks --export-task-ids $EXP_ID --output text | head -n1 | awk '{print $3}'`
  sleep 30
  echo $status
done

echo "Step 8 - Move the instance to Glacier"
EXP_FILE=`aws s3 ls s3://$S3_EXP_Bucket/vms/ | awk '{print $4}'`
aws s3 cp s3://$S3_EXP_Bucket/vms/$EXP_FILE s3://$S3_EXP_Bucket/vms/$EXP_FILE --storage-class DEEP_ARCHIVE

###############################################################
# Author: Mr. Z @dumpstarfire
# Title: Export EC2 to S3 Bucket
# Email: dumpstarfire@gmail.com
###############################################################
