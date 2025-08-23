.PHONY: ⚙️  # make all commands phony

app=EP-0249

${app}/lib/ina3221.py:
	curl https://wiki.52pi.com/images/b/b3/Ina3221.zip | tar -xvf - -C ${app}/lib

${app}/lib/ssd1306.py:
	curl https://wiki.52pi.com/images/e/e6/Ssd1306.zip | tar -xvf - -C ${app}/lib

${app}/rp2-pico-latest.uf2: ⚙️  ## Download the main application code
	curl -q https://micropython.org/download/rp2-pico/rp2-pico-latest.uf2 -o $@

demo_sel = h3:has(span\#Demo_code) ~ pre
demo_url = https://wiki.52pi.com/index.php?title=EP-0249

${app}/main.py: ⚙️  ## Install dependencies
	@echo "Extracting demo code from ${demo_url}... (requires curl and python3 and beautifulsoup4)"
	python3 ../py/docquery/main.py <(curl https://wiki.52pi.com/index.php?title=EP-0249) -i -s "${demo_sel}" > $@

download: ⚙️  ## Download dependencies
	@echo "Downloading dependencies..."
	@mkdir -p ${app}/lib
	$(MAKE) ${app}/lib/ina3221.py
	$(MAKE) ${app}/lib/ssd1306.py
	$(MAKE) ${app}/main.py
	$(MAKE) ${app}/rp2-pico-latest.uf2

pico_host = pi4-admin
pico_user = uwe
pico_dir  = /home/${pico_user}/micropy/${app}
ssh       = ssh ${pico_user}@${pico_host}

upload: ⚙️  ## Upload to the device
	@echo "Assuming the device is connected via USB to the host ${pico_host}."
	@echo "Uploading to ${pico_user}@${pico_host}:${pico_dir}..."
	$(ssh) "mkdir -p ${pico_dir}"
	rsync -avz --delete ${app}/ ${pico_user}@${pico_host}:${pico_dir}/
	@$(ssh) "tree ${pico_dir}"
	@echo "✅ Files uploaded to ${pico_user}@${pico_host}:${pico_dir}"

upgrade: ⚙️  ## Update the application on the device
	@echo "Upgrading runtimne and application on the device (requires bootloader mode)..."
	$(MAKE) download upload
	$(ssh) 'make -C ${pico_dir} mount upgrade update info umount'

remote-help:
	@echo "Available remote commands:"
	@make -C ${app} help

remote-%: ⚙️ upload ## Run a remote command on the bridge host
	$(ssh) 'make -C ${pico_dir} $*'

which: ⚙️  ## Show which Python is used
	@echo "python:  $$(which python3)"
	@echo "pip:     $$(which pip)"
	@echo "ipython: $$(which ipython3)"
	@# try to import beautifulsoup4
	@python3 -c "import bs4; print('bs4 version:', bs4.__version__)" || echo "bs4 not installed"

include ../../scripts/usage.mk