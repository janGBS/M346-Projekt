import csv
import json
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    # Hol die Dateiinfo aus dem Event
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    target_bucket = 'json-out'
    target_key = source_key.replace('.csv', '.json')

    # CSV aus S3 lesen
    csv_file = s3.get_object(Bucket=source_bucket, Key=source_key)['Body'].read().decode('utf-8')
    csv_reader = csv.DictReader(csv_file.splitlines())

    # JSON konvertieren
    json_data = json.dumps([row for row in csv_reader], indent=4)

    # JSON zurück in S3 schreiben
    s3.put_object(Bucket=target_bucket, Key=target_key, Body=json_data)

    return {
        'statusCode': 200,
        'body': f'{source_key} wurde in {target_key} konvertiert.'
    }
