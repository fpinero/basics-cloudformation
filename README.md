## Deployment of an S3 Bucket for Terraform State using CloudFormation

This guide provides instructions on how to create an S3 bucket using AWS CloudFormation, 
which will be used by Terraform to store its state file.

### CloudFormation Template for S3 Bucket
The following is a basic CloudFormation template to create an S3 bucket with versioning 
enabled, suitable for storing Terraform state:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'CloudFormation to create an S3 bucket for Terraform state'

Resources:
  TerraformStateBucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: your-unique-bucket-name
      VersioningConfiguration:
        Status: Enabled

  BucketPolicy:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref TerraformStateBucket
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: 'AllowSSEPut'
            Effect: 'Allow'
            Principal: '*'
            Action: 's3:PutObject'
            Resource: !Sub 'arn:aws:s3:::your-unique-bucket-name/*'
            Condition:
              StringEquals:
                's3:x-amz-server-side-encryption': 'AES256'
```
Replace your-unique-bucket-name with your desired bucket name.

## Configuring Terraform to Use the S3 Bucket
After deploying the bucket with CloudFormation, configure Terraform to use this bucket 
for its remote state:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-bucket-name"
    key            = "path/to/my/terraform.tfstate"
    region         = "your-aws-region"
    encrypt        = true
    dynamodb_table = "optional-dynamodb-lock-table-name"
    acl            = "private"
  }
}
```
Replace your-unique-bucket-name, your-aws-region, and path/to/my/terraform.tfstate with your specific values.

## Executing the CloudFormation Template
To deploy the template:

- Prerequisites:
    - Ensure AWS CLI is installed and configured with your credentials and default region.

- Deploy the Template:
    - Save your template as my-s3-bucket.yaml.
    - Run the following command:
```commandline
aws cloudformation create-stack --stack-name my-stack-s3 --template-body file://my-s3-bucket.yaml --region eu-central-1
```
- Verify Stack Creation:
    - Use the AWS CLI or AWS Management Console to check the status of your stack.

## Additional Notes

* **Error Handling**: Check the AWS CloudFormation console for any errors during stack creation.
* **Stack Deletion**: To delete the stack and its resources, use:
```commandline
aws cloudformation delete-stack --stack-name my-stack-s3 --region eu-central-1
```

