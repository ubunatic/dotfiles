.PHONY: ⚙️  # make all non-file targets phony

SHELL    := bash
godconf  := cd $$DOTFILES/apps/go/godconf  && go run main.go
gohiccup := cd $$DOTFILES/apps/go/gohiccup && go run main.go

# define empty optional arguments (for make completion)
godconf_args =
DRYRUN =
ifdef DRYRUN
godconf_args += dry
endif

include ../../scripts/usage.mk  # default target is 'usage' now
usage: info          ## Show project info and basic help message
help: usage-all ⚙️   ## Show extended help message (excl. project info)

info: ⚙️  ## Show project info (variables, paths, etc.)
	@echo Project Info:
	# godconf source:  $(DOTFILES)/apps/go/godconf
	# gohiccup source: $(DOTFILES)/apps/go/gohiccup
	# settings file:   $(DOTFILES)/config/gnome/settings.json
	# dconf database:  $(HOME)/.config/dconf/user
	# dconf tools:     dconf gsettings gnome-tweaks dconf-editor
	# DRYRUN:          $(DRYRUN)
	# godhiccup:       $(gohiccup)
	# godconf:         $(godconf)
	# godconf_args:    $(godconf_args)

debug: ⚙️  ## Show debug info for various targets
	@echo -e "------------------------ Project Info --------------------------"
	$(MAKE) info
	@echo -e "------------------------ Make Help -----------------------------"
	$(MAKE) help
	@echo -e "------------------------ Godconf Build -------------------------"
	$(MAKE) sections
	@echo -e "------------------------ Shell Settings ------------------------"
	$(MAKE) shell
	@echo -e "------------------------ Keybindings ---------------------------"
	$(MAKE) keybindings

update: write-settings  ## Alias for write-settings

clean: disable-custom-keybindings  ## Alias for disable-custom-keybindings

godconf:  ## Build godconf
	source $$DOTFILES/shell/userrc.sh && DEBUG=1 dotapps build
	test -e $$DOTFILES/bin/godconf
	@echo "✅ godconf built"

sections: ⚙️  ## Show all sections in dconf
	dconf dump / | grep -E '^\[.*' | sed 's:\[\|\]::g'

shell: ⚙️  ## Show all gnome shell settings in dconf
	dconf dump /org/gnome/shell/

keybindings: ⚙️  ## Show all keybindings in dconf
	dconf dump /org/gnome/shell/keybindings/
	dconf dump /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/

editor: ⚙️  ## Open dconf editor
	dconf-editor &

write-settings: ⚙️  ## Write all settings
	# TODO: apply settings.json
	@echo "✅ Done writing settings (not implemented yet)"
	$(MAKE) update-keybindings

update-keybindings: ⚙️  ## Set custom keybindings in dconf
	@echo "Set the list of custom keybindings..."
	$(godconf) $(godconf_args) update-keybindings
	@echo "✅ Done setting custom keybindings"

disable-custom-keybindings: ⚙️  ## Disable all custom keybindings (except custom0, custom1, etc.)
	@echo "Disable all custom keybindings (except custom0, custom1, etc.)..."
	$(godconf) $(godconf_args) disable-custom-keybindings
	@echo "✅ Done disabling custom keybindings"

watch-hiccups: ⚙️  ## Watch for hiccups and log them
	$(gohiccup)
