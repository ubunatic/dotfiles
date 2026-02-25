# Google Workspace Access – Setup Guide

One-time setup to allow `make google-read` and `make google-copy` to access
private Google Docs/Sheets.

## Prerequisites

- [`gcloud` CLI](https://cloud.google.com/sdk/docs/install) installed and on `$PATH`
- Access to the Google account that owns the documents

## Steps

### 1. Authenticate with Drive scope

```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/drive.readonly,\
https://www.googleapis.com/auth/cloud-platform
```

A browser window will open. Log in with the account that has access to the docs.

### 2. Set a quota project

```bash
gcloud auth application-default set-quota-project <your-gcp-project-id>
```

Use a project you have access to. Run `gcloud projects list` if you are unsure which to use.

### 3. Enable the Drive API for that project

```bash
gcloud services enable drive.googleapis.com --project=<your-gcp-project-id>
```

Only needed once per project. Takes ~30 seconds to propagate.

## Test

```bash
make google-read URL="https://docs.google.com/document/d/<doc-id>/edit"
```

Should print the document content to stdout.

## Troubleshooting

| Error | Fix |
|-------|-----|
| `invalid_grant` / `reauth related error` | Re-run step 1 |
| `ACCESS_TOKEN_SCOPE_INSUFFICIENT` | Re-run step 1 (missing Drive scope) |
| `quota project … not set` | Run step 2 |
| `drive.googleapis.com … disabled` | Run step 3 |
| `File not found` (404) | The Drive API is working, but the doc is on a Shared Drive — should be handled automatically; check if the URL is correct and your account has access |

## Non-interactive / CI Use

Set `GOOGLE_CREDENTIALS` to a service account JSON key file with
`https://www.googleapis.com/auth/drive.readonly` scope granted:

```bash
export GOOGLE_CREDENTIALS=/path/to/sa-docsrepo.json
make google-read URL="..."
```

Keep the key file **outside** the repo — never commit credentials.
