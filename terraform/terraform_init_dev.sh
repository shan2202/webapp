#!/bin/bash

echo "#########################################################"
echo "#     Terraform Initialization for scb-dev     #"
echo "#########################################################"
echo ""

BUCKETNAME="872132143780-tfstate-bucket"
REGION="ap-southeast-1"
DDBTABLENAME="tfstate-table"
PROJECT_NAME="scb"

terraform init -upgrade -reconfigure -backend=true -backend-config="bucket=$REGION-$BUCKETNAME" -backend-config="key=$PROJECT_NAME/terraform.tfstate" -backend-config="region=$REGION" -backend-config="dynamodb_table=$REGION-$DDBTABLENAME"
terraform workspace select -or-create dev