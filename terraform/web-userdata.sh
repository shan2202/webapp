#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16
cd ~/
echo $APP_BUCKET_NAME
aws s3 cp s3://$WEB_BUCKET_NAME/web-tier/build web-tier/build --recursive
sudo amazon-linux-extras install nginx1 -y
cd /etc/nginx
ls
sudo rm nginx.conf
sudo aws s3 cp s3://$WEB_BUCKET_NAME/nginx.conf .
sudo service nginx restart
chmod -R 755 /home/ec2-user
sudo chkconfig nginx on

