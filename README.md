
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

# Testbericht

**Durchgeführt am:** 20.12.2024, 22:00  

**Durchgeführt von:** jan.hollenstein@edu.gbssg.ch

**Dokumentiert von:** pascal.aeschbacher@edu.gbssg.ch

---

## Bucket-Erstellung

<img width="299" alt="image" src="https://github.com/user-attachments/assets/42b57b72-0691-47d8-9c46-71d16d101777" />

### Ergebnis

Die Buckets wurden erfolgreich erstellt mit den Namen:  
- `csv-to-json-in-09da2236`  
- `csv-to-json-out-cad38f94`
  
Die generierten Namen enthalten eindeutige IDs, wodurch Namenskonflikte ausgeschlossen werden.

### Mögliche Fehlerquellen und Lösungen

1. **Falsche Region:**
   - Region in der Datei `init.sh` auf `us-east-1` setzen.
2. **Falsche AWS Credentials:**
   - Zugangsdaten korrekt konfigurieren, wie in der Dokumentation beschrieben (`aws configure`).
3. **Cloud-Dienst nicht aktiv:**
   - AWS Cloud-Dienste starten und sicherstellen, dass die Umgebung verfügbar ist.
4. **Bucket existiert bereits:**
   - Aufgrund der ID am Ende des Namens ist dies unwahrscheinlich. Falls es dennoch passiert, den bestehenden Bucket manuell in der AWS-Konsole löschen.

---

## Erstellung der Lambda-Funktion

<img width="498" alt="image" src="https://github.com/user-attachments/assets/397b88f4-e2a2-42a1-a62f-3839faf0b00d" />

### Ergebnis

Die Lambda-Funktion wurde erfolgreich erstellt und mit den korrekten Parametern konfiguriert. Alle Einstellungen entsprechen der Vorlage, und die Funktion ist einsatzbereit.

### Mögliche Fehlerquellen und Lösungen

1. **Datei nicht vorhanden:**
   - Pfad zur Lambda-Datei überprüfen. Solange das Git-Repository nicht manuell verändert wurde, sollte der Pfad korrekt sein.
2. **Funktion existiert bereits:**
   - Falls die Funktion bereits existiert, wird sie durch das Skript automatisch gelöscht und neu erstellt. Sollte dies nicht geschehen, die Funktion manuell in der AWS-Konsole entfernen.
3. **IAM-Rollenberechtigungen:**
   - Die IAM-Rolle `LabRole` muss die erforderlichen Berechtigungen besitzen. Diese werden beim Skriptstart ausgelesen und als Variable gespeichert.

---

## CSV-Upload und JSON-Download

<img width="396" alt="image" src="https://github.com/user-attachments/assets/d3904f5d-eb3e-47c2-895c-843c1f04247b" />

### Ergebnis

Die CSV-Datei wurde erfolgreich in den Input-Bucket hochgeladen und anschließend von der Lambda-Funktion in eine JSON-Datei umgewandelt. Die Ausgabe wurde im Output-Bucket gespeichert.  
Zusätzlich wurde getestet, ob unterschiedliche Delimiter-Zeichen (z. B. `;`, `,`, `|`) korrekt verarbeitet werden. Alle Tests waren erfolgreich.

### Mögliche Fehlerquellen und Lösungen

1. **Datei nicht vorhanden:**
   - Standardmäßig ist die Datei korrekt im Repository enthalten. Wurde das Repository manuell geändert, muss der Pfad im Code angepasst werden.
2. **Timeout-Fehler:**
   - Sollte die Lambda-Funktion länger als 15 Sekunden für die Verarbeitung benötigen, das Skript erneut ausführen. Beim zweiten Versuch tritt der Fehler in der Regel nicht mehr auf.
3. **Falsche Ausgabe beim Download:**
   - Ungültige oder nicht angepasste Delimiter-Zeichen können die Konvertierung beeinträchtigen. Stellen Sie sicher, dass die verwendeten Delimiter im Code korrekt gesetzt sind.

---

## Fazit

Alle Tests wurden erfolgreich durchgeführt, und die erwarteten Ergebnisse konnten erzielt werden. Potenzielle Fehler wurden analysiert und entsprechende Lösungen dokumentiert, um eine reibungslose Ausführung des Projekts sicherzustellen.

## Reflexion

### Reflexion Jan Hollenstein

Dieses Projekt war für mich eine spannende und lehrreiche Erfahrung. Besonders hat mir gefallen, dass wir die Möglichkeit hatten, selbstständig an den Aufgaben zu arbeiten und Verantwortung für verschiedene Aspekte des Projekts zu übernehmen. Allerdings musste ich feststellen, dass die Zeit, die uns in der Schule dafür zur Verfügung stand, etwas knapp bemessen war. Gerade in der Anfangsphase hätten wir mehr Zeit benötigt, um uns besser zu organisieren und die Aufgaben klarer aufzuteilen. Zu Beginn waren wir als Team nicht optimal strukturiert, und es hat etwas gedauert, bis wir wirklich effektiv zusammengearbeitet haben.

Eine besondere Herausforderung waren für mich die Berechtigungen im Code, da die Benutzerdaten von Andrin fest programmiert waren. Diese Situation hat anfangs für Verwirrung gesorgt und den Fortschritt etwas verzögert. Sobald wir das jedoch angepasst hatten, lief die technische Umsetzung reibungslos, und ich konnte das Projekt auch erfolgreich auf meiner eigenen VM testen, was ein sehr motivierender Moment war.

Trotz der anfänglichen Schwierigkeiten war die Zusammenarbeit im Team eine positive Erfahrung. Nach der ersten Orientierungsphase haben wir die Aufgaben sinnvoll aufgeteilt und konnten so effizient vorgehen. Besonders beeindruckend fand ich, wie schnell wir gemeinsam Lösungen für auftretende Probleme gefunden haben.

Insgesamt bin ich stolz darauf, dass wir es geschafft haben, das Projekt innerhalb des vorgegebenen Zeitrahmens erfolgreich abzuschließen. Dieses Projekt hat mir nicht nur technische Kenntnisse vermittelt, sondern auch gezeigt, wie wichtig Organisation und Teamarbeit sind, um ein gemeinsames Ziel zu erreichen.
### Reflexion Pascal

Eine AWS Lambda Funktion zu erstellen und zu testen war lehrreich und interessant.
Wir haben am Afang lange gebraucht um uns in das Projekt einzuarbeiten und die Aufgaben zu verteilen.
Wir hätten dafür ein wenig mehr Zeit in der Schule benötigt, weil es in Person einfacher war das Projekt miteinander zu besprechen.
Die selbständige Arbeit in der Gruppe hat mir Spass bereitet. Wir haben gut harmoniert und miteinander eine aktive Kommunikation gepflegt.

### Reflexion Andrin 

Ich fand das Projekt spannend und die Aufgabenstellung hat zu einer interessanten Lösung geführt. Am Anfang waren wir nicht sehr organisiert was uns Zeit gekostet hat. Wir hätten dadurch das Projekt einige Zeit früher schon abschliessen können. Auch hatten wir ein wenig Schwierigkeiten mit dem Git was die Commit Historie ein wenig durcheinander macht. 

Die Berechtigung der LabRole hat uns etwas Schwierigkeiten besorgt. Zuerst haben wir die falsche Rolle benutzt und danach habe ich ausversehen meinen role arn hardgecoded. Das heisste die anderen zwei konnten das Skript nicht mehr testen und ich machte das immer bis wir es dan dynamisch gelöst haben. Aber ansonsten sind wir relativ gut vorangekommen.


