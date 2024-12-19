import csv
import json
import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    # Logging der Event-Daten
    print(f"Event received: {event}")

    try:
        # Dateiinfo aus dem Event extrahieren
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        source_key = event['Records'][0]['s3']['object']['key']
        print(f"Source bucket: {source_bucket}, Source key: {source_key}")

        # Output-Bucket aus Umgebungsvariable
        target_bucket = os.environ.get('OUTPUT_BUCKET')
        if not target_bucket:
            raise ValueError("OUTPUT_BUCKET environment variable is not set")
        print(f"Target bucket: {target_bucket}")

        target_key = source_key.replace('.csv', '.json')

        # CSV aus S3 lesen
        csv_file = s3.get_object(Bucket=source_bucket, Key=source_key)['Body'].read().decode('utf-8')
        csv_reader = csv.DictReader(csv_file.splitlines())

        # JSON konvertieren
        json_data = json.dumps([row for row in csv_reader], indent=4)

        # JSON zurück in S3 schreiben
        s3.put_object(Bucket=target_bucket, Key=target_key, Body=json_data)
        print(f"File successfully converted and saved to {target_bucket}/{target_key}")

        return {
            'statusCode': 200,
            'body': f'{source_key} wurde in {target_key} konvertiert.'
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': str(e)
        }
