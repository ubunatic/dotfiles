.PHONY: ⚙️  # make all non-file targets phony

include .env # if not present, the .env target will called

export HOMELAB_DEVELOPER_OS
export HOMELAB_NAS_CONNECTION
export HOMELAB_MAC_CONNECTION
# All other connection use the defaults defined in inventory/homelab.ini.

export HOMELAB_BOOTSTRAP_BUCKET
export HOMELAB_BOOTSTRAP_FOLDER
export HOMELAB_BOOTSTRAP_PROJECT

export GOOGLE_CLOUD_PROJECT ?= $(HOMELAB_BOOTSTRAP_PROJECT)

.env:  ## Create a .env file from the example (if it doesn't exist)
	@cp .env .env.bak 2> /dev/null || true
	cp .env.example .env
	@echo "Created .env from .env.example"
	@echo "⚠️ Please edit .env, set the correct values, and re-run"; exit 1

vars: inventory-vars
inventory-vars: ⚙️  bootstrap-vars  ## Show inventory variables
	@echo "Homelab Variables (env.mk, .env):"
	@env | grep '^HOMELAB_' | grep -v '^HOMELAB_BOOTSTRAP_' | sort | awk '{print "  "$$0}'
	@echo ""
	@echo "Cloud Variables (env.mk, .env):"
	@env | grep '^GOOGLE_' | awk '{print "  "$$0}'
	@echo ""

vars: ⚙️  ## Show all make variables
	@echo "# NOTE: Add more variables using 'var: <var-target>'"
