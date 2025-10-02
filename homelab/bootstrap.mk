.PHONY: ⚙️  # make all non-file targets phony

include .env  # if not present, the .env target will called

BOOTSTRAP_URL = $(HOMELAB_BOOTSTRAP_BUCKET)/$(HOMELAB_BOOTSTRAP_FOLDER)
SUDO = 1  # unset to disable sudo for bootstrap commands
ifdef SUDO
sudo = sudo
endif

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

bootstrap-ansible: ⚙️  ## Check that ansible is installed
	@$(sudo) echo "running bootstrap with sudo='$(sudo)'"
	$(sudo) apt update && $(sudo) apt install -y ansible ansible-lint git libsecret-tools
	ansible-galaxy collection install -r requirements.yml

password_name = homelab-vault-current
bootstrap-ansible-vault: ⚙️  ## Check that the Ansible Vault password is stored in secret-tool
	@echo "👀 Checking Ansible Vault password '$(password_name)' in secret-tool"
	@secret-tool lookup service "$(password_name)" >/dev/null || \
	   (echo "🔑 Enter the Ansible Vault password '$(password_name)' to store in secret-tool:"; \
		secret-tool store --label='Homelab Vault: $(password_name)' service "$(password_name)"; \
		secret-tool lookup service "$(password_name)" >/dev/null)
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
