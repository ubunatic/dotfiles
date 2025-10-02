# Vault Directory
This directory contains Ansible Vault files used for encrypting sensitive information such as service account credentials and secrets.These files are essential for securely managing access to various services and should be handled with care.

## Bootstrapping Vault Files
To set up the necessary vault files on your machine, follow these steps:
1. Ensure you have the `gsutil` CLI tool installed on your machine
2. Ensure your Terminal session is authenticated with a Google account
3. Ensure this Google account has access to the Google Drive folder where the vault files are stored.
4. Ensure you have the Ansible Vault password to decrypt the files.

```bash
# Create the vault directory if it doesn't exist
gcloud config set project YOUR_PROJECT_ID
gcloud auth login --update-adc --no-launch-browser
# run inside homelab directory
mkdir -p .vault
gsutil cp -r gs://YOUR_BUCKET_NAME/FOLDER_NAME .vault
```
