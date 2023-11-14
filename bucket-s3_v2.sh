#!/bin/bash

# User and profile data
#NAVIFY_USERNAME="pineroef"
#LOGIN_ALIAS="devops-alias"
#AWS_PROFILE_NAME="roche-devops-profile"

# Read the password from the environment variable
NAVIFY_PASSWORD="${PASSWD_NAVIFY}"

# Check if the password is available
if [ -z "$NAVIFY_PASSWORD" ]; then
    echo "Error: Password not found in environment variable."
    exit 1
fi

# Authentication with navify-aws-sso-login
#navify-aws-sso-login --username "$NAVIFY_USERNAME" --password "$NAVIFY_PASSWORD" --login-alias "$LOGIN_ALIAS" --write-credentials "$AWS_PROFILE_NAME"

# Set AWS profile
export AWS_PROFILE="$AWS_PROFILE_NAME"

# Bucket name and region
BUCKET_NAME="bucket-name"
REGION="eu-central-1"

# Check if the bucket already exists
if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket already exists."
else
    echo "Creating bucket..."
    aws cloudformation create-stack --stack-name my-s3-stack --template-body file://bucket-s3.yaml --region $REGION
fi

# Initialize and plan Terraform (avoid apply)
terraform init
terraform plan
