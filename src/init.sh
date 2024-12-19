#!/bin/bash

# Fail on any error
set -e

# Variablen
AWS_REGION="us-east-1"
IN_BUCKET_NAME="csv-to-json-in-bucket-$(date +%s)"
OUT_BUCKET_NAME="csv-to-json-out-bucket-$(date +%s)"
LAMBDA_ROLE_NAME="CsvToJsonLambdaRole"

echo "AWS Region: $AWS_REGION"
echo "Input Bucket: $IN_BUCKET_NAME"
echo "Output Bucket: $OUT_BUCKET_NAME"
echo "Lambda Role: $LAMBDA_ROLE_NAME"

# 1. S3 Buckets erstellen
echo "Creating S3 buckets..."
aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"

echo "Buckets created: $IN_BUCKET_NAME and $OUT_BUCKET_NAME"

# 2. IAM Role für Lambda erstellen
echo "Creating IAM Role for Lambda..."
ROLE_POLICY=$(cat <<EOF
{
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
}
EOF
)
echo "$ROLE_POLICY" > lambda-trust-policy.json
aws iam create-role --role-name "$LAMBDA_ROLE_NAME" --assume-role-policy-document file://lambda-trust-policy.json

echo "Attaching policies to role..."
aws iam attach-role-policy --role-name "$LAMBDA_ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
aws iam attach-role-policy --role-name "$LAMBDA_ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess"

# Cleanup temporary file
rm lambda-trust-policy.json

# 3. Lambda Funktion vorbereiten (ohne Bereitstellung des Codes)
echo "Lambda role created and policies attached. You can now deploy your Lambda function."

# Ausgabe der Bucket-Namen und Rolle
echo "-----------------------------"
echo "Setup complete!"
echo "Input Bucket Name: $IN_BUCKET_NAME"
echo "Output Bucket Name: $OUT_BUCKET_NAME"
echo "Lambda Role Name: $LAMBDA_ROLE_NAME"
echo "-----------------------------"
