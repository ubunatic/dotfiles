.PHONY: ⚙️  # make all non-file targets phony

include .env # if not present, the .env target will called

export HOMELAB_PI4_USER
export HOMELAB_PI4_ADMIN_USER
export HOMELAB_PI400_USER

export HOMELAB_DEVELOPER_OS
export HOMELAB_NAS_CONNECTION
export HOMELAB_MAC_CONNECTION

export HOMELAB_BOOTSTRAP_BUCKET
export HOMELAB_BOOTSTRAP_FOLDER
export HOMELAB_BOOTSTRAP_PROJECT

export GOOGLE_CLOUD_PROJECT ?= $(HOMELAB_BOOTSTRAP_PROJECT)

.env:  ## Create a .env file from the example (if it doesn't exist)
	@cp .env .env.bak 2> /dev/null || true
	cp .env.example .env
	@echo "Created .env from .env.example"
	@echo "⚠️ Please edit .env, set the correct values, and re-run"; exit 1

inventory-vars:
	@echo "Inventory Variables (env.mk, .env):"
	@echo "  HOMELAB_PI4_USER        = '$$HOMELAB_PI4_USER'"
	@echo "  HOMELAB_PI4_ADMIN_USER  = '$$HOMELAB_PI4_ADMIN_USER'"
	@echo "  HOMELAB_PI400_USER      = '$$HOMELAB_PI400_USER'"
	@echo ""
	@echo "Localhost/Developer Machine Variables:"
	@echo "  HOMELAB_DEVELOPER_OS    = '$$HOMELAB_DEVELOPER_OS'"
	@echo "  HOMELAB_NAS_CONNECTION  = '$$HOMELAB_NAS_CONNECTION'"
	@echo "  HOMELAB_MAC_CONNECTION  = '$$HOMELAB_MAC_CONNECTION'"
	@echo "  GOOGLE_CLOUD_PROJECT    = '$$GOOGLE_CLOUD_PROJECT'"
	@echo ""

bucket-vars:
	@echo "Bootstrap Bucket Variables (env.mk, .env):"
	@echo "  HOMELAB_BOOTSTRAP_BUCKET  = '$$HOMELAB_BOOTSTRAP_BUCKET'"
	@echo "  HOMELAB_BOOTSTRAP_FOLDER  = '$$HOMELAB_BOOTSTRAP_FOLDER'"
	@echo "  HOMELAB_BOOTSTRAP_PROJECT = '$$HOMELAB_BOOTSTRAP_PROJECT'"

vars: ⚙️ playbook-vars inventory-vars bucket-vars ## Show all make variables