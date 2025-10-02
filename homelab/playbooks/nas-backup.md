# Rclone Backup Playbook

This playbook performs backups of specified directories to a Google Cloud Storage bucket using `rclone`. It is designed to be run on a local machine and utilizes Ansible's capabilities to manage the backup process efficiently.

## Prerequisites
- Ansible installed on the local machine.
- `gcloud` CLI installed and configured.
  - Make sure the correct project is set: `gcloud config set project YOUR_PROJECT_ID`
  - Make sure `gcloud auth login` works.

## Playbook Overview
- Runs on the local machine.
- Uses `google.cloud` collection for Google Cloud interactions.
- Sets up service account credentials for Google Cloud if not already present.
- Configures `rclone` with the necessary credentials and settings.
- Creates rclone configuration file if it does not exist.
- Uses `rclone` command to sync directories to a Google Cloud Storage bucket.
- Performs the backup operation.
- Requires `google_*` and `rclone_*` variables to be defined in the inventory or group variables.
- Keep existing SA files and secrets as they are when re-running the playbook (stateless IaC)

### Variables
- `google_cloud_project`: The Google Cloud project ID.
- `google_cloud_project_number`: The Google Cloud project number.
- `google_cloud_bucket_location`: The location for the Google Cloud Storage bucket.
- `google_cloud_backup_bucket`: The name of the Google Cloud Storage bucket for backups.
- `google_cloud_bucket_storage_class`: The storage class for the Google Cloud Storage bucket.
- `rclone_config`: Path to the rclone configuration file.
- `rclone_remote`: Name of the rclone remote to use.
- `rclone_service_account_file`: Path to the rclone service account JSON file.
- `rclone_backup_sources`: List of directories to back up.

### rclone config example
```
[drive]
type = drive
scope = drive.file
team_drive =

# client_id to be set dynamically by rclone config command
client_id = 123456789123-example.apps.googleusercontent.com

# client_secret to be set dynamically by rclone config command
client_secret = CLIENT_SECRET

# token to be set dynamically by rclone config command
token = {}

[gcs]
type = google cloud storage
project_number = 123456789123
service_account_file = ~/.config/rclone/rclone-projectname-service-account.json
bucket_policy_only = true
bucket_acl = private
location = eu
storage_class = MULTI_REGIONAL
```

## Service Account Setup
At first, we will use simple service account credentials that last forever.
Later we can switch to short-lived credentials if needed.
Service account files should be stored securely and not hardcoded in the playbook.
The files can live next to the rclone config file.

### Encrypting Service Account Files
To ensure the security of service account files, it is recommended to encrypt them using Ansible Vault.
This way, sensitive information is protected and only accessible to authorized users.
Here is a basic example of how to encrypt a service account file:
```bash
ansible-vault encrypt /path/to/service_account_file.json
```
When running the playbook, you will need to provide the vault password to decrypt the file.
```yaml
- name: Decrypt service account file
  ansible.builtin.command:
    cmd: ansible-vault decrypt /path/to/service_account_file.json
  when: not service_account_file_decrypted.stat.exists
```
After decryption, ensure that the file permissions are set appropriately to restrict access.
```bash
chmod 600 /path/to/service_account_file.json
```

### Bootstrap Configuration/Files
The to avoid having any host/user-specific files in the repo (even encrypted ones), we can have an encrypted
bootstrap configuration that we manually pull from a secure location and decrypt on the target machine.

Currently, this includes all (encrypted) vault files which are stored in `homelab/vault/` directory.
These files are pulled from Google Drive using `gdrive` CLI tool, which must be available on this machine.
