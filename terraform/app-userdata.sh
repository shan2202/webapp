#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16
npm install -g pm2
cd ~/
echo $APP_BUCKET_NAME
aws s3 cp s3://$APP_BUCKET_NAME/app-tier/ app-tier --recursive
cd ~/app-tier
npm install
pm2 start index.js
pm2 startup
pm2 save