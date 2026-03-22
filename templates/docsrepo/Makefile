.PHONY: ⚙️  # make all non-file targets phony

SHELL    := bash
SLACKBOT := .code/scripts/slackbot.applescript
PYTHON   := .code/venv/bin/python3

# Load variables from .docsrepo config file
SLACKBOT_URL  := $(shell source .docsrepo && echo "$$DOCSREPO_SLACKBOT_URL")
SLACKBOT_HINT := $(shell source .docsrepo && echo "$$DOCSREPO_SLACKBOT_HINT")
ORIGIN        := $(shell source .docsrepo && echo "$$DOCSREPO_ORIGIN")

# Generic vars use by multiple tools
FILE=
SRC=
DST=

# Some tools use env vars
export DOCSREPO_SLACKBOT_URL=$(SLACKBOT_URL)

venv: ⚙️  ## create/update Python venv and install requirements
	python3 -m venv .code/venv && .code/venv/bin/pip install -q -r .code/requirements.txt

info: ⚙️  ## show help and variable values
	@.code/scripts/info.sh

help: ⚙️ info  ## alias for info

sync: ⚙️  ## sync generic tools and guides from origin
	.code/scripts/sync-docsrepo.sh sync

save: ⚙️  ## save generic tools and guides back to origin
	.code/scripts/sync-docsrepo.sh save

list-save: ⚙️  ## list files that would be saved to origin
	.code/scripts/sync-docsrepo.sh list-save

list-sync: ⚙️  ## list files that would be synced from origin
	.code/scripts/sync-docsrepo.sh list-sync

sync-vars: ⚙️  ## sync only the .docsrepo config file from origin
	.code/scripts/sync-docsrepo.sh vars

commit: ⚙️  ## commit changes locally
	git add . && git commit -m "Update docs"
	@echo "Don't forget to push your changes to a backup remote repo"

time: ⚙️  ## show current time
	@date +"%Y-%m-%d %H:%M:%S"

date: ⚙️  ## show current date
	@date +"%Y-%m-%d"

copy: ⚙️  ## copy a file from SRC to DST (SRC=... DST=...)
	@cp ${SRC} ${DST}

move: ⚙️  ## move a file from SRC to DST (SRC=... DST=...)
	@mv ${SRC} ${DST}


## Tool Integrations

code: ⚙️  ## open a file in the default code editor (FILE=...)
	@code ${FILE}

slackbot: ⚙️  ## send a prompt to Slackbot (PROMPT=...)
	test -n "$$DOCSREPO_SLACKBOT_URL" # ensure URL is set in env
	test -n "$(SLACKBOT_HINT)"        # ensure the hint is set as make var
	test -n "$(PROMPT)"               # ensure the prompt is set as make var
	${SLACKBOT} "${PROMPT} (Note: ${SLACKBOT_HINT})"

mail: ⚙️  ## list inbox envelopes
	@command -v himalaya >/dev/null || (echo "himalaya not found — run: brew install himalaya" && exit 1)
	himalaya envelope list

mail-read: ⚙️  ## read a message (ID=...)
	@test -n "$(ID)" || (echo "Usage: make mail-read ID=<message-id>" && exit 1)
	himalaya message read $(ID)

mail-search: ⚙️  ## search inbox (QUERY=...)
	@test -n "$(QUERY)" || (echo "Usage: make mail-search QUERY=<search-terms>" && exit 1)
	himalaya envelope list --query "$(QUERY)"

eml: ⚙️  ## print EML file as Markdown (FILE=...)
	@test -n "$(FILE)" || (echo "Usage: make eml FILE=<path.eml>" && exit 1)
	$(PYTHON) .code/scripts/eml2md.py "$(FILE)"

eml-save: ⚙️  ## convert EML to .md file alongside the original (FILE=...)
	@test -n "$(FILE)" || (echo "Usage: make eml-save FILE=<path.eml>" && exit 1)
	$(PYTHON) .code/scripts/eml2md.py "$(FILE)" --save "$(dir $(FILE))"

eml-extract: ⚙️  ## extract attachments from EML to <name>-attachments/ dir (FILE=...)
	@test -n "$(FILE)" || (echo "Usage: make eml-extract FILE=<path.eml>" && exit 1)
	$(PYTHON) .code/scripts/eml2md.py "$(FILE)" --extract-attachments

eml-all: ⚙️  ## convert EML to .md and extract attachments (FILE=...)
	@test -n "$(FILE)" || (echo "Usage: make eml-all FILE=<path.eml>" && exit 1)
	$(PYTHON) .code/scripts/eml2md.py "$(FILE)" --save "$(dir $(FILE))" --extract-attachments

zip-review: ⚙️  ## print all EML files from a ZIP as Markdown (FILE=...)
	@test -n "$(FILE)" || (echo "Usage: make zip-review FILE=<path.zip>" && exit 1)
	$(PYTHON) .code/scripts/zip-review.py "$(FILE)"

zip-review-save: ⚙️  ## save all EML files from a ZIP to a single .md review file (FILE=...)
	@test -n "$(FILE)" || (echo "Usage: make zip-review-save FILE=<path.zip>" && exit 1)
	$(PYTHON) .code/scripts/zip-review.py "$(FILE)" --save

vision: ⚙️  ## run OCR/vision on image (IMG=...; optional: PROMPT="..." MODEL="...")
	@test -n "$(IMG)" || (echo "Usage: make vision IMG=<path> [PROMPT=\"...\"] [MODEL=\"...\"]" && exit 1)
	@$(MAKE) ensure-macmon
	$(PYTHON) .code/scripts/ollama-vision.py "$(IMG)" $(if $(MODEL),--model "$(MODEL)") $(if $(PROMPT),--prompt "$(PROMPT)")

receipt: ⚙️  ## scan accounting document: invoice, receipt, membership form, SEPA (IMG=...; optional: MODEL="...")
	@test -n "$(IMG)" || (echo "Usage: make receipt IMG=<path> [MODEL=\"...\"]" && exit 1)
	@$(MAKE) ensure-macmon
	$(PYTHON) .code/scripts/ollama-vision.py "$(IMG)" --mode accounting $(if $(MODEL),--model "$(MODEL)")

doc: ⚙️  ## convert document to markdown (FILE=...; SOURCE=ollama|claude; MODEL=phi4; OUTPUT=path.md)
	@test -n "$(FILE)" || (echo "Usage: make doc FILE=<path> [SOURCE=claude] [MODEL=phi4] [OUTPUT=path.md]" && exit 1)
	$(if $(MODEL),OLLAMA_MODEL=$(MODEL),) $(PYTHON) .code/scripts/doc2md.py "$(FILE)" $(if $(SOURCE),--source $(SOURCE),) $(if $(OUTPUT),--output $(OUTPUT),)

pdf2img: ⚙️  ## convert PDF pages to PNG images (FILE=...; output: <basename>-page-<N>.png)
	@test -n "$(FILE)" || (echo "Usage: make pdf2img FILE=<path.pdf>" && exit 1)
	$(PYTHON) .code/scripts/pdf2img.py "$(FILE)"

mlx-vision: ⚙️  ## run OCR/vision on image via MLX (IMG=...; optional: PROMPT="..." MODEL="...")
	@test -n "$(IMG)" || (echo "Usage: make mlx-vision IMG=<path> [PROMPT=\"...\"] [MODEL=\"...\"]" && exit 1)
	@$(MAKE) ensure-macmon
	$(PYTHON) .code/scripts/mlx-vision.py "$(IMG)" $(if $(MODEL),--model "$(MODEL)") $(if $(PROMPT),--prompt "$(PROMPT)")

mlx-receipt: ⚙️  ## scan accounting document via MLX (IMG=...; optional: MODEL="...")
	@test -n "$(IMG)" || (echo "Usage: make mlx-receipt IMG=<path> [MODEL=\"...\"]" && exit 1)
	@$(MAKE) ensure-macmon
	$(PYTHON) .code/scripts/mlx-vision.py "$(IMG)" --mode accounting $(if $(MODEL),--model "$(MODEL)")

ensure-macmon: ⚙️  ## ensure macmon exporter is running (auto-started by AI tasks)
	@curl -sf http://localhost:9102/metrics >/dev/null 2>&1 || (nohup $(PYTHON) .code/scripts/macmon-exporter.py >/tmp/macmon-exporter.log 2>&1 & echo "macmon exporter started")

macmon-exporter: ⚙️  ## start Apple Silicon Prometheus exporter on port 9102
	$(PYTHON) .code/scripts/macmon-exporter.py
