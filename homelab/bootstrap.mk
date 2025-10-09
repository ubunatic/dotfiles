.PHONY: ⚙️  # make all non-file targets phony

include .env  # if not present, the .env target will called

ifndef HOMELAB_DEVELOPER_OS
$(error HOMELAB_DEVELOPER_OS not set in .env)
endif

BOOTSTRAP_URL = $(HOMELAB_BOOTSTRAP_BUCKET)/$(HOMELAB_BOOTSTRAP_FOLDER)
SUDO = 1  # unset to disable sudo for bootstrap commands
ifdef SUDO
sudo = sudo
endif

with_common = source playbooks/scripts/common.sh;

.env:  ## Create a .env file from the example (if it doesn't exist)
	@cp .env .env.bak 2> /dev/null || true
	cp .env.example .env
	@echo "Created .env from .env.example"
	@echo "⚠️ Please edit .env, set the correct values, and re-run"; exit 1

bootstrap-vars: ⚙️ .env
	@echo "Bootstrap Env Variables:"
	@echo "  HOMELAB_BOOTSTRAP_BUCKET:  '$(HOMELAB_BOOTSTRAP_BUCKET)'"
	@echo "  HOMELAB_BOOTSTRAP_PROJECT: '$(HOMELAB_BOOTSTRAP_PROJECT)'"
	@echo "  HOMELAB_BOOTSTRAP_FOLDER:  '$(HOMELAB_BOOTSTRAP_FOLDER)'"
	@echo "Bootstrap Make Variables:"
	@echo "  BOOTSTRAP_URL: '$(BOOTSTRAP_URL)'"

vars: bootstrap-vars

bootstrap: ⚙️ .env ## Bootstrap this homelab setup (install dependencies)
	$(MAKE) bootstrap-bucket
	$(MAKE) bootstrap-ansible
	$(MAKE) bootstrap-ansible-vault password_name=homelab-vault-current
	$(MAKE) bootstrap-ansible-vault password_name=homelab-vault-previous
	$(MAKE) bootstrap-rclone-sa

bootstrap-ansible: ⚙️ bootstrap-ansible-$(HOMELAB_DEVELOPER_OS) ## Check that ansible is installed

bootstrap-ansible-linux: ⚙️  ## Check that ansible is installed on Linux
	@$(sudo) echo "running bootstrap with sudo='$(sudo)'"
	$(sudo) apt update && $(sudo) apt install -y ansible ansible-lint git libsecret-tools make
	ansible-galaxy collection install -r requirements.yml

bootstrap-ansible-mac: ⚙️  ## Check that ansible is installed on macOS
	brew install ansible git make
	ansible-galaxy collection install -r requirements.yml

password_name = homelab-vault-current
bootstrap-ansible-vault: ⚙️  ## Check that the Ansible Vault password is stored in secret-tool
	@echo "👀 Checking Ansible Vault password '$(password_name)' in secret-tool"
	@$(with_common) secret-tool-lookup-or-store "$(password_name)" "Homelab Vault: $(password_name)" >/dev/null
	@echo "✅ Ansible Vault password '$(password_name)' is stored in secret-tool"

gsutil gcloud: ⚙️  ## Check that gsutil and gcloud are installed
	@if which gsutil > /dev/null; \
	then echo "✅ gsutil found"; \
	else echo "⚠️ WARNING! gsutil not found, please install the Google Cloud SDK: https://cloud.google.com/sdk/docs/install"; \
	fi

gsutil = $(shell which gsutil 2> /dev/null || echo '@echo ⚠️ DRYRUN: gsutil')

bootstrap-bucket: ⚙️ .env gsutil  ## Create the bootstrap bucket in Google Cloud (if it doesn't exist)
	@echo "🪧 To log in to Google Cloud, run: gcloud auth login --update-adc # optionally with --no-launch-browser"
	@echo "🪣 Creating bootstrap bucket $(HOMELAB_BOOTSTRAP_BUCKET) in project $(HOMELAB_BOOTSTRAP_PROJECT)"
	test -z "$(HOMELAB_BOOTSTRAP_EXAMPLE)"  # check that the user edited .env
	$(gsutil) du -sh "$(HOMELAB_BOOTSTRAP_BUCKET)" || \
	$(gsutil) mb -p "$(HOMELAB_BOOTSTRAP_PROJECT)" "$(HOMELAB_BOOTSTRAP_BUCKET)"
	$(MAKE) bootstrap-bucket-sync
	@echo "✅ Bootstrap bucket 🪣 is ready and synced 🔁"

bootstrap-bucket-sync: ⚙️ .env gsutil  ## Sync the .vault directory with the bootstrap bucket
	@echo "🔁 Syncing .vault/ with $(BOOTSTRAP_URL)/"
	$(gsutil) rsync -ru .vault/ "$(BOOTSTRAP_URL)/"
	$(gsutil) rsync -ru "$(BOOTSTRAP_URL)/" .vault/
	@echo "🪧 Deletions are not synced, so old files may remain in the bucket"
	@echo "✅ Sync complete"

bootstrap-bucket-sync-force: ⚙️ .env gsutil  ## Force sync the .vault directory with the bootstrap bucket (deleting files)
	@echo "⚠️ WARNING! This will delete files in the bucket that are not in .vault/"
	@echo "🔁 Force syncing .vault/ with $(BOOTSTRAP_URL)/"
	$(gsutil) rsync -rd .vault/ "$(BOOTSTRAP_URL)/"
	$(gsutil) rsync -rd "$(BOOTSTRAP_URL)/" .vault/
	@echo "✅ Force sync complete"

bootstrap-rclone-sa: ⚙️ .env gsutil  ## Create a service account for rclone access (if it doesn't exist)
	playbooks/scripts/gcloud-sa-create.sh "$(HOMELAB_BOOTSTRAP_PROJECT)" rclone .vault/rclone
	playbooks/scripts/ansible-vault-encrypt.sh .vault/rclone/*
	$(MAKE) bootstrap-bucket-sync
	@echo "✅ rclone service account is ready, credentials are encrypted in .vault/rclone/ and synced to the bucket"

## Bootstrap Shortcuts
ansible:    bootstrap-ansible            ## Shortcut for bootstrap-ansible
bucket:     bootstrap-bucket             ## Shortcut for bootstrap-bucket
rclone-sa:  bootstrap-rclone-sa          ## Shortcut for bootstrap-rclone-sa
sync:       bootstrap-bucket-sync        ## Shortcut for bootstrap-bucket-sync
sync-force: bootstrap-bucket-sync-force  ## Shortcut for bootstrap-bucket-sync-force
vault:      bootstrap-ansible-vault      ## Shortcut for bootstrap-ansible-vault
mac:        bootstrap-ansible-mac        ## Shortcut for bootstrap-ansible-mac
linux:      bootstrap-ansible-linux      ## Shortcut for bootstrap-ansible-linux
