.PHONY: ⚙️  # make all non-file targets phony

include ../scripts/usage.mk
include *.mk

help: usage ⚙️  ## Show this help message

playbook-vars: ⚙️
	@echo "Playbook Make Variables:"
	@echo "  PLAYBOOK:            '$(PLAYBOOK)'"
	@echo "  PLAYBOOK_EXTRA_ARGS: [$(PLAYBOOK_EXTRA_ARGS)]"

PLAYBOOK=playbooks/host-common.yml
ifdef DEBUG
PLAYBOOK_EXTRA_ARGS=-vv
endif

# check HOMELAB_DEVELOPER_OS
# if linux -> ignore "mac" in inventory/local.ini
ifeq ($(HOMELAB_DEVELOPER_OS),linux)
PLAYBOOK_EXTRA_ARGS+= --limit '!mac'
endif

debug: DEBUG=1
debug: setup ⚙️  ## Run the setup for a specific target in debug mode
setup: ⚙️ ## Run ansible playbook to setup all machines in the homelab
	sudo echo "enabled sudo for ansible"
	ansible-playbook -i inventory/local.ini $(PLAYBOOK_EXTRA_ARGS) $(PLAYBOOK)

setup-host-common:    ⚙️ ## Setup the common tools
setup-host-ansible:   ⚙️ ## Setup the ansible environment
setup-nas-containers: ⚙️ ## Setup the NAS containers
setup-nas-backup:     ⚙️ ## Setup/Run the backup

debug-%: ⚙️; $(MAKE) debug PLAYBOOK=playbooks/$*.yml
setup-%: ⚙️; $(MAKE) setup PLAYBOOK=playbooks/$*.yml

lint: ⚙️  ## Run ansible-lint on all playbooks
	ansible-lint playbooks/*.yml

## Shortcuts

nas:     setup-nas-containers
bak:     setup-nas-backup
host:    setup-host-common
ansible: setup-host-ansible
common:  setup-host-common
all:     setup

dev: ⚙️  ## Run the current playbook in debug mode
	$(MAKE) debug PLAYBOOK=playbooks/nas-backup.yml
