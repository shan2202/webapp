#!/bin/bash

sudo yum update -y
sudo yum install mysql -y
APP_BUCKET=$(aws ssm get-parameter --name APP_BUCKET --region=ap-southeast-1 --output text --query Parameter.Value)
echo $APP_BUCKET
cd ~/
aws s3 cp s3://$APP_BUCKET/ApplicationLayer/ /home/ec2-user/ApplicationLayer --recursive
cd /home/ec2-user/ApplicationLayer/
pip3 install -r requirements.txt
aws configure set region "ap-southeast-1"
nohup python3 app.py &