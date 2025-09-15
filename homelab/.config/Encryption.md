# Encrypted Homelab Configurations
This directory contains configuration files for my homelab setup.
This dir will typically contain sensitive information and should be kept private.

Use the script `crypt.sh` to encrypt and decrypt these files.

## Encrypt
```mermaid
flowchart TD
    Plain[Plaintext Config Files...]
    TGZ[Tarball Archive]
    Vault[Encrypted Archive]
    GPG[GPG Encryption/Decryption]
    Key[Public GPG User key]

    Plain -->|create tarball| TGZ
    TGZ -->|read file| GPG -->|write file| Vault
    Key -->|read file| GPG
```

## Decrypt
```mermaid
flowchart TD
    Vault[Encrypted Archive]
    GPG[GPG Encryption/Decryption]
    Key[Private GPG User key]
    Password[Password Prompt]
    TGZ[Tarball Archive]
    Plain[Plaintext Config Files...]

    Vault -->|read file| GPG -->|write file| TGZ -->|extract tarball| Plain
    Key -->|read file| GPG
    Password -->|request GPG key unlock| GPG
```

## Security Assessment
- The encryption uses GPG with asymmetric encryption, which is generally secure.
- Ensure that the private GPG key is kept secure and not shared.
- The script uses `tar` and `gzip` for archiving, which are standard tools.
- Backup the encrypted archive (`config.tar.gz.gpg`) to prevent data loss.
- Backup the GPG key pair and remember the passphrase for the private key to avoid being locked out of your data.
- Security horizon: 10 years, assuming strong passphrase and key management. After 10 years:
  - Rotate stored secrets.
  - Re-encrypt files with a new GPG key pair.
