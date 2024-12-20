
# Setup-Anleitung

## Schritt 1: Linux Ubuntu Maschine starten
1. Starten Sie Ihre Linux Ubuntu Maschine.
2. Öffnen Sie das Terminal.

---

## Schritt 2: Git-Repository klonen
### Voraussetzungen:
- Vergewissern Sie sich, dass `git` auf Ihrer Maschine installiert ist.
- Falls nicht, folgen Sie [dieser Anleitung](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), um `git` zu installieren.

### Repository klonen:
```bash
git clone https://github.com/janGBS/M346-Projekt.git
```

---

## Schritt 3: AWS Cloud vorbereiten
1. **AWS Academy Learner Lab** aufrufen: [AWS Academy](https://awsacademy.instructure.com/).
2. Melden Sie sich an und starten Sie Ihre Cloud-Instanz.
3. Sobald das grüne Licht leuchtet:
   - Kopieren Sie den AWS-CLI Key aus den **AWS Details**.
<img width="1880" alt="image" src="https://github.com/user-attachments/assets/4cd8195c-041a-4c2f-ba8d-9f55d5ad2831" />

---

## Schritt 4: Key auf der Linux-Maschine einfügen
1. Wechseln Sie zurück zu Ihrer Linux Maschine.
2. Fügen Sie den kopierten Key in die Datei `.aws/credentials` ein.

### Verbindung testen:
Führen Sie folgenden Befehl aus, um die Verbindung zu prüfen:
```bash
# Verbindungstest
aws sts get-caller-identity
```

---

## Schritt 5: AWS CLI installieren (falls nicht vorhanden)
1. Aktualisieren Sie die Paketlisten:
    ```bash
    sudo apt update
    ```
2. Installieren Sie AWS CLI:
    ```bash
    sudo apt install -y awscli
    ```
3. Testen Sie die Installation:
    ```bash
    aws --version
    ```

---
# Aufbau des Services

Der Service basiert auf der Verwendung von AWS Cloud-Diensten und ist in folgende Hauptkomponenten unterteilt:

---

## Projektaufbau
```
projektverzeichnis/ 
│ 
├── src/ 
│   ├── init.sh
|   ├── lambda_function.py  
│   └── tests/
│       ├── testdata.csv  
│       └── testdata.json 
├── README.md # Dokumentation 
├── Reflexion_ASU.md # Reflexion von ASU 
├── Reflexion_JHO.md # Reflexion von JHO 
└── Reflexion_PAE.md # Reflexion von PAE
```

## AWS S3-Buckets:

- **Input Bucket**:Hier werden CSV-Dateien hochgeladen.
- **Output Bucket**: Speichert die konvertierten JSON-Dateien.

## AWS Lambda-Funktion:

- Wird durch S3-Events ausgelöst.
- Liest CSV-Dateien aus dem Input Bucket und schreibt JSON-Dateien in den Output Bucket.
- Unterstützt einstellbare Parameter wie Delimiter über Umgebungsvariablen.

## Bash-Skript (`init.sh`):

- Automatisiert die Erstellung der AWS-Ressourcen.
- Deployt die Lambda-Funktion.
- Testet die Konvertierungsfunktion durch Hochladen einer Beispiel-CSV-Datei.

---

# Lambda-Funktion

Die Lambda-Funktion konvertiert CSV-Daten in JSON. Sie enthält folgende Schlüsselaspekte:

## Trigger:

- Wird durch das Hochladen einer Datei in den Input Bucket ausgelöst.

## Parameter:

- Der Delimiter der CSV-Dateien kann über die Umgebungsvariable `CSV_DELIMITER` angepasst werden (Standard: Semikolon).

## Fehlerbehandlung:

- Bei Fehlern werden diese geloggt und eine Fehlermeldung wird zurückgegeben.

## Output:

- Die JSON-Datei wird im Output Bucket mit der gleichen Basisdateiname gespeichert, jedoch mit der Endung `.json`.

---

# Testdaten

## Beispiel CSV-Datei (Eingabe):

```csv
ID;Nachname;Vorname;Strasse;PLZ;Ort;Tel
1;Scheidegger;Urs;Griittbachstrasse 2;4542;Luterbach;032 682 51 37
```

## Erwartete JSON-Ausgabe:

```JSON
[
   {
      "ID": "1",
      "Nachname": "Scheidegger",
      "Vorname": "Urs",
      "Strasse": "Griittbachstrasse 2",
      "PLZ": "4542",
      "Ort": "Luterbach",
      "Tel": "032 682 51 37"
   }
]
```

# Fehlerprotokollierung

## S3-Events:

- Falls ein Fehler auftritt, z. B. durch eine ungültige CSV-Datei, wird dies im CloudWatch-Log festgehalten.
  
## Lambda-Ausgabe:

- **Bei Erfolg**: `StatusCode 200` mit einer Erfolgsnachricht.
- **Bei Fehlern**: `StatusCode 500` und eine detaillierte Fehlermeldung. 
