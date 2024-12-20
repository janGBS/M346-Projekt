#!/bin/bash
set -e
 
AWS_REGION="us-east-1"
IN_BUCKET_NAME="csv-to-json-in-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
OUT_BUCKET_NAME="csv-to-json-out-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
LAMBDA_ROLE_NAME="CsvToJsonLambdaRole"
LAMBDA_FUNCTION_NAME="CsvToJsonFunction"
INPUT_FILE="tests/testdata.csv"
OUTPUT_FILE="tests/destata.json"
 
echo "Creating S3 buckets in $AWS_REGION..."
if [ "$AWS_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION"
    aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION"
else
    aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi
 
echo "Packaging Lambda function..."
LAMBDA_ZIP="lambda_function.zip"
zip -j "$LAMBDA_ZIP" lambda_function.py
 
echo "Checking if Lambda function exists..."
if aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" > /dev/null 2>&1; then
    echo "Lambda function $LAMBDA_FUNCTION_NAME already exists. Skipping creation."
else
    echo "Deploying Lambda function..."
    LAMBDA_ROLE_ARN=arn:aws:iam::066083534964:role/LabRole
    aws lambda create-function --function-name "$LAMBDA_FUNCTION_NAME" \
        --runtime python3.9 \
        --role ${LAMBDA_ROLE_ARN} \
        --handler lambda_function.lambda_handler \
        --zip-file fileb://"$LAMBDA_ZIP" \
        --environment "Variables={OUTPUT_BUCKET=$OUT_BUCKET_NAME}" \
        --timeout 15
fi
 
echo "Adding Lambda permission for S3..."
aws lambda add-permission \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --principal s3.amazonaws.com \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::${IN_BUCKET_NAME} \
 
echo "Setting up S3 event trigger for Lambda..."
aws s3api put-bucket-notification-configuration --bucket "$IN_BUCKET_NAME" --notification-configuration '{
    "LambdaFunctionConfigurations": [
        {
            "LambdaFunctionArn": "'$(aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" --query 'Configuration.FunctionArn' --output text)'",
            "Events": ["s3:ObjectCreated:*"]
        }
    ]
}'
 
echo "Uploading file to Input Bucket..."
aws s3 cp "$INPUT_FILE" "s3://$IN_BUCKET_NAME/$INPUT_FILE"
 
echo "Waiting for Lambda to process the file..."
sleep 10  # Wartezeit, damit Lambda die Datei verarbeitet
 
echo "Downloading result from Output Bucket..."
aws s3 cp "s3://$OUT_BUCKET_NAME/$INPUT_FILE.json" "$OUTPUT_FILE"
 
echo "Output JSON file downloaded. Displaying content:"
cat "$OUTPUT_FILE"
 
echo "Setup and processing complete!"
echo "Input Bucket Name: $IN_BUCKET_NAME"
echo "Output Bucket Name: $OUT_BUCKET_NAME"
echo "Lambda Function Name: $LAMBDA_FUNCTION_NAME"
