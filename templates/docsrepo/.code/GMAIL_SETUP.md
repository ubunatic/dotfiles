# Gmail Access – Setup Guide

One-time setup to allow `make mail` and related targets to access your Gmail inbox
via [Himalaya](https://github.com/soywod/himalaya), a CLI email client.

## Prerequisites

- [`himalaya`](https://github.com/soywod/himalaya) installed: `brew install himalaya`
- A Gmail account with IMAP enabled
- A Gmail app password (not your regular Google password)

## Steps

### 1. Enable IMAP in Gmail

Gmail Settings → See all settings → Forwarding and POP/IMAP → **Enable IMAP** → Save.

### 2. Generate an App Password

Google Account → Security → 2-Step Verification → **App passwords**
Create a password for "Mail" / "Mac" (or any label you choose).
Copy the 16-character password — you only see it once.

### 3. Store the password in macOS Keychain

Himalaya uses a generic keychain entry named after the account. Replace `<account>` with the account name from your Himalaya config (the part after `accounts.` in the toml, e.g. `gmail`):

```bash
security add-generic-password -a '<account>' -s 'himalaya-<account>-imap' -w
```

You will be prompted to enter the app password. No output means success.

This keeps credentials out of config files.

### 4. Create the Himalaya config

Create `~/.config/himalaya/config.toml`:

```toml
[accounts.gmail]
default = true
display-name = "Your Name"
email = "your@gmail.com"

backend.type = "imap"
backend.host = "imap.gmail.com"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "your@gmail.com"
backend.auth.type = "password"
backend.auth.cmd = "security find-generic-password -a '<account>' -s 'himalaya-<account>-imap' -w"
```

Replace `your@gmail.com` and `Your Name` with your actual values.

### 5. Test

```bash
make mail
```

Should list your inbox messages.

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Authentication failed` | Re-generate the app password (step 2) and re-run step 3 |
| `IMAP not enabled` | Re-check Gmail settings (step 1) |
| `command not found: himalaya` | Run `brew install himalaya` |
| Keychain prompt on first run | Allow access once; tick "Always allow" |

## Notes

- Never put the app password in a config file or commit it to git
- The `backend.auth.cmd` reads the password from Keychain at runtime
- IMAP gives read/write access; treat it like your inbox
