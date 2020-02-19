#!/bin/bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text > rhel.txt
while read p; do   aws ec2 get-console-output --instance-id $p --output text > /tmp/instance_console;   grep -q "Red Hat Enterprise" /tmp/instance_console && echo -e Instance $p && aws ec2 get-console-output --instance-id $p --output text | grep "Red Hat Enterprise Linux [0-9]."; done <rhel.txt
aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text > ubuntu.txt
while read p; do   aws ec2 get-console-output --instance-id $p --output text > /tmp/instance_console;   grep -q "Ubuntu" /tmp/instance_console && echo -e Instance $p  && aws ec2 get-console-output --instance-id $p --output text | grep "Ubuntu **."; done <ubuntu.txt
