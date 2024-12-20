
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

