# Datei:          init.sh
# Autor:          jan.hollenstein@edu.gbssg.ch, pascal.aeschbacher@edu.gbssg.ch, andrin.Sutter@edu.gbssg.ch
# Datum:          20.12.2024
# Version:        1.9
# Beschreibung:   Bash-Skript für automatisiertes Erstellen von Buckets, Lambda-Funktion erstellen und CSV-Datei in JSON-Datei umwandeln in AWS Cloud.

#!/bin/bash
set -e

# AWS-Region und Bucket-Namen definieren
AWS_REGION="us-east-1"
IN_BUCKET_NAME="csv-to-json-in-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
OUT_BUCKET_NAME="csv-to-json-out-$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)"
LAMBDA_ROLE_NAME="LabRole"  # Name der Rolle, nicht die ARN
LAMBDA_FUNCTION_NAME="CsvToJsonFunction"
INPUT_FILE="tests/testdata.csv"
OUTPUT_FILE="tests/testdata.json"

# Abrufen der ARN für die LabRole
echo "Retrieving ARN for IAM role $LAMBDA_ROLE_NAME..."
LAMBDA_ROLE_ARN=$(aws iam get-role --role-name "$LAMBDA_ROLE_NAME" --query "Role.Arn" --output text 2>/dev/null)

if [ -z "$LAMBDA_ROLE_ARN" ]; then
    echo "Error: IAM role $LAMBDA_ROLE_NAME does not exist in this AWS account."
    echo "Please create the role and rerun this script."
    exit 1
fi
echo "Role ARN retrieved: $LAMBDA_ROLE_ARN"

# Buckets erstellen
echo "Creating S3 buckets in $AWS_REGION..."
if [ "$AWS_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION"
    aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION"
else
    aws s3api create-bucket --bucket "$IN_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    aws s3api create-bucket --bucket "$OUT_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
fi

# Lambda-Funktion erstellen
echo "Packaging Lambda function..."
LAMBDA_ZIP="lambda_function.zip"
zip -j "$LAMBDA_ZIP" lambda_function.py

# Bestehende Lambda-Funktion überprüfen und löschen, falls vorhanden
echo "Checking if Lambda function exists..."
if aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" > /dev/null 2>&1; then
    echo "Lambda function $LAMBDA_FUNCTION_NAME exists. Deleting it..."
    aws lambda delete-function --function-name "$LAMBDA_FUNCTION_NAME"
    echo "Lambda function $LAMBDA_FUNCTION_NAME deleted."
fi

# Neue Lambda-Funktion bereitstellen
echo "Deploying Lambda function..."
aws lambda create-function --function-name "$LAMBDA_FUNCTION_NAME" \
    --runtime python3.9 \
    --role ${LAMBDA_ROLE_ARN} \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://"$LAMBDA_ZIP" \
    --environment "Variables={OUTPUT_BUCKET=$OUT_BUCKET_NAME}" \
    --timeout 15

# Berechtigungen für die Lambda-Funktion hinzufügen
echo "Adding Lambda permission for S3..."
aws lambda add-permission \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --principal s3.amazonaws.com \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::${IN_BUCKET_NAME}

# S3-Event-Trigger für die Lambda-Funktion einrichten
echo "Setting up S3 event trigger for Lambda..."
aws s3api put-bucket-notification-configuration --bucket "$IN_BUCKET_NAME" --notification-configuration '{
    "LambdaFunctionConfigurations": [
        {
            "LambdaFunctionArn": "'$(aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" --query 'Configuration.FunctionArn' --output text)'",
            "Events": ["s3:ObjectCreated:*"]
        }
    ]
}'

# Datei in den Eingabebucket hochladen und Verarbeitung testen
echo "Uploading file to Input Bucket..."
aws s3 cp "$INPUT_FILE" "s3://$IN_BUCKET_NAME/$INPUT_FILE"

# Wartezeit, damit Lambda die Datei verarbeiten kann
echo "Waiting for Lambda to process the file..."
seconds=15
while [ $seconds -gt 0 ]; do
    echo -ne "
Waiting: $seconds seconds remaining..."
    sleep 1
    : $((seconds--))
done

# Ergebnis aus dem Ausgabebucket herunterladen
echo "\nDownloading result from Output Bucket..."
aws s3 cp "s3://$OUT_BUCKET_NAME/$OUTPUT_FILE" "$OUTPUT_FILE"

# Ergebnis anzeigen
echo "Output JSON file downloaded. Displaying content:"
cat "$OUTPUT_FILE"

# Abschlussmeldung
echo "Setup and processing complete!"
echo "Input Bucket Name: $IN_BUCKET_NAME"
echo "Output Bucket Name: $OUT_BUCKET_NAME"
echo "Lambda Function Name: $LAMBDA_FUNCTION_NAME"
