#!/bin/bash
set -e

AWS_REGION="us-east-1"
IN_BUCKET_NAME="csv-to-json-in-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
OUT_BUCKET_NAME="csv-to-json-out-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
LAMBDA_ROLE_NAME="CsvToJsonLambdaRole"

echo "Creating S3 buckets in $AWS_REGION..."
if [ "$AWS_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION"
    aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION"
else
    aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

echo "Creating IAM Role for Lambda..."
if ! aws iam get-role --role-name "$LAMBDA_ROLE_NAME" 2>/dev/null; then
    aws iam create-role --role-name "$LAMBDA_ROLE_NAME" --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'
    aws iam attach-role-policy --role-name "$LAMBDA_ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    aws iam attach-role-policy --role-name "$LAMBDA_ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess"
else
    echo "IAM Role $LAMBDA_ROLE_NAME already exists."
fi

echo "Setup complete!"
echo "Input Bucket Name: $IN_BUCKET_NAME"
echo "Output Bucket Name: $OUT_BUCKET_NAME"
echo "Lambda Role Name: $LAMBDA_ROLE_NAME"
