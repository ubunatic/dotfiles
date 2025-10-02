
inventory-vars:
	@echo "Inventory Variables:"
	@echo "  HOMELAB_PI4_USER        = '$(HOMELAB_PI4_USER)'"
	@echo "  HOMELAB_PI4_ADMIN_USER  = '$(HOMELAB_PI4_ADMIN_USER)'"
	@echo "  HOMELAB_PI400_USER      = '$(HOMELAB_PI400_USER)'"

vars: ⚙️ playbook-vars inventory-vars bootstrap-vars ## Show all make variables