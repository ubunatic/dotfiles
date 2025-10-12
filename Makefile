.PHONY: ⚙️  # make all non-file targets phony

# catchall: forward all targets to homelab/Makefile
%: ⚙️
	@$(MAKE) -C homelab $@
