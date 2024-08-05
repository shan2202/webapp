#!/bin/bash

sudo yum update -y
aws configure set region "ap-southeast-1"
WEB_BUCKET=$(aws ssm get-parameter --name WEB_BUCKET --region=ap-southeast-1 --output text --query Parameter.Value)
echo $WEB_BUCKET
cd ~/
aws s3 cp s3://$WEB_BUCKET/WebLayer/ /home/ec2-user/WebLayer --recursive
cd /home/ec2-user/WebLayer/
pip3 install -r requirements.txt
nohup /usr/local/bin/gunicorn -b 0.0.0.0:8000 app:app &
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx
APP_LB_DNS=$(aws elbv2 describe-load-balancers --names scb-elb-app --query LoadBalancers[].DNSName --output text) 
echo $APP_LB_DNS
sed -i "s/<DNS_of_Internal_ALB>/$APP_LB_DNS/g" nginx.conf
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx

