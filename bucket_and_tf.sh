#!/bin/bash

BUCKET_NAME="bucket-name"
REGION="eu-central-1"

# Let's see if the bucket already exists
if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket already exists."
else
    echo "Creating bucket..."
    aws cloudformation create-stack --stack-name mi-stack-s3 --template-body file://bucket-s3.yaml --region $REGION
fi

# Init and plan Terraform, let's avoid apply
terraform init
terraform plan

