#!/bin/bash
#Step 1 - Create AMI of the Snapshot
[[ $1 ]] && SNAPSHOT_ID=$1 || read -p "`echo -e '\nNothing was entered.\nPlease Enter an Instance: '`" SNAPSHOT_ID
S3_EXP_Bucket=$SNAPSHOT_ID-export
#Step 2 - Locate Snapshot Region
for region in `aws ec2 describe-regions --output text | cut -f3`
do
     aws ec2 describe-snapshots --owner self --region $region | grep $SNAPSHOT_ID && REGION_SN=$region
done
# Step 3 - Create AMI from Snapshot
SNAP_AMI=`aws ec2 register-image --region us-east-2 --name $SNAPSHOT_ID-AMI --block-device-mappings DeviceName=/dev/sda1,Ebs={SnapshotId=$SNAPSHOT_ID} --virtualization-type hvm --architecture x86_64 --root-device-name /dev/sda1 --output text`
# Step 4: Create an S3 Bucket to export the Instance
aws s3api create-bucket --bucket $S3_EXP_Bucket --region $REGION_SN --create-bucket-configuration LocationConstraint=$REGION_SN
# Step 5 - Export AMI
EXP_ID=`/usr/local/aws-cli/v2/current/bin/aws ec2 export-image --image-id $SNAP_AMI --disk-image-format VMDK --s3-export-location S3Bucket=$S3_EXP_Bucket,S3Prefix=exports/ --output text | head -n1 | awk '{print $2}'`
# Step 6 - Monitoring the export
status=active
until [ $status == completed ]
do
  echo "testing for active"
  status=`/usr/local/aws-cli/v2/current/bin/aws ec2 describe-export-image-tasks --export-image-task-ids $EXP_ID --output text | head -n1 | awk '{print $3}'`
  sleep 30
  echo $status
done
# Step 7 - Move the instance to Glacier
EXP_FILE=`/usr/local/aws-cli/v2/current/bin/aws s3 ls s3://$S3_EXP_Bucket/exports/ | awk '{print $4}'`
/usr/local/aws-cli/v2/current/bin/aws s3 cp s3://$S3_EXP_Bucket/exports/$EXP_FILE s3://$S3_EXP_Bucket/exports/$EXP_FILE --storage-class DEEP_ARCHIVE
