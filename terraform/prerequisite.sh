#!/bin/bash
BUCKETNAME="872132143780-tfstate-bucket"
REGION="ap-southeast-1"
DDBTABLENAME="tfstate-table"
#Create S3 bucket to store tfstate file with versioning enbaled.
aws s3api create-bucket --bucket $REGION-$BUCKETNAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION
aws s3api put-bucket-versioning --bucket $REGION-$BUCKETNAME --versioning-configuration Status=Enabled

aws dynamodb create-table --table-name $REGION-$DDBTABLENAME --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region $REGION 