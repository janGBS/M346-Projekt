# Datei:          lambda_function.py
# Autor:          [Ihr Name]
# Datum:          20.12.2024
# Version:        1.1
# Beschreibung:   AWS Lambda-Funktion zur Konvertierung von CSV-Dateien in JSON-Dateien mit einstellbaren Parametern wie Delimiter.

import csv
import json
import boto3
import os

def lambda_handler(event, context):
    """
    AWS Lambda-Handler zum Konvertieren einer CSV-Datei in eine JSON-Datei.

    Anforderungen:
    - Die Funktion wird durch S3-Events ausgelöst.
    - CSV-Dateien werden aus einem Quell-Bucket gelesen und als JSON-Dateien in einen Ziel-Bucket geschrieben.

    Parameter:
    - Delimiter (Trennzeichen) kann über die Umgebungsvariable CSV_DELIMITER angepasst werden.

    Argumente:
    - event: Das Ereignis, das die Lambda-Funktion auslöst (dict).
    - context: Kontextinformationen zur Ausführung (objekt).

    Rückgabe:
    - dict: StatusCode und Nachricht.
    """
    # Initialisierung des S3-Clients
    s3 = boto3.client('s3')

    # Logging des eingehenden Events
    print(f"Event received: {event}")

    try:
        # Dateiinformationen aus dem Event extrahieren
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        source_key = event['Records'][0]['s3']['object']['key']
        print(f"Source bucket: {source_bucket}, Source key: {source_key}")

        # Ziel-Bucket aus Umgebungsvariablen abrufen
        target_bucket = os.environ.get('OUTPUT_BUCKET')
        if not target_bucket:
            raise ValueError("OUTPUT_BUCKET environment variable is not set")
        print(f"Target bucket: {target_bucket}")

        # Ziel-Schlüssel (Key) für JSON-Datei erstellen
        target_key = source_key.replace('.csv', '.json')

        # Delimiter aus Umgebungsvariablen abrufen (Standard: Komma)
        delimiter = os.environ.get('CSV_DELIMITER', ';')
        print(f"Using delimiter: '{delimiter}'")

        # CSV-Datei aus S3 lesen
        csv_file = s3.get_object(Bucket=source_bucket, Key=source_key)['Body'].read().decode('utf-8')
        csv_reader = csv.DictReader(csv_file.splitlines(), delimiter=delimiter)

        # CSV-Daten in JSON konvertieren
        json_data = json.dumps([row for row in csv_reader], indent=4)

        # JSON-Datei in den Ziel-Bucket schreiben
        s3.put_object(Bucket=target_bucket, Key=target_key, Body=json_data)
        print(f"File successfully converted and saved to {target_bucket}/{target_key}")

        # Erfolgsnachricht zurückgeben
        return {
            'statusCode': 200,
            'body': f'{source_key} wurde in {target_key} konvertiert.'
        }

    except Exception as e:
        # Fehlerbehandlung und Logging
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': str(e)
        }
