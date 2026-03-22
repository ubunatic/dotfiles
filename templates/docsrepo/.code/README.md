# Code and Scripts

This dir contains all code and scripts required to aurtomate my work life
with this DocsRepo.

No code must live outside of this dir except for the main `Makefile`.

## How to add new code

- start in `.code/scripts/`
- if it grows too big create a small CLI in Go using Cobra as `.code/<tool>/cmd/`
 -  a Go module is already prepared (see `go.mod`)
 -  but do not add any dependencies until we actually need them
- KISS - keep it simple and stupid
  - do not over-engineer
  - do not add unnecessary dependencies
  - do not add unnecessary features
  - do not add unnecessary complexity

## Tools

### google-dl

Downloads Google Workspace documents (Docs, Sheets) and exports them to
Markdown or CSV. Used via root `Makefile` targets:

```bash
make google-read URL=<google-doc-url>
make google-copy URL=<url> REF_DIR=<dir> REF_NAME=<filename>
```

See [GOOGLE_SETUP.md](./GOOGLE_SETUP.md) for one-time authentication setup.

### himalaya (Gmail)

CLI access to Gmail inbox via IMAP. Used via root `Makefile` targets:

```bash
make mail                    # list inbox
make mail-read ID=<id>       # read a message
make mail-search QUERY=<q>   # search
```

See [GMAIL_SETUP.md](./GMAIL_SETUP.md) for one-time authentication setup.
