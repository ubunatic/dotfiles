up down rm:
	# Starting immich.ml, press CTRL+C to stop the stack.
	# After that, the stopped stack will be visible in your container UI.
	# You can restart it there. It will also restart when your container
	# env restarts, e.g., when rebooting the system.
	podman compose -f immich.ml.yml $@

help:
	@cat Readme.md | grep -E '^- .*' | sed -e 's|host:port|$(host):$(port)|g'

port = $(shell grep -E 'ports:' -A1 immich.ml.yml | grep -oE '[0-9]+:[0-9]+' | cut -d: -f1)
host = $(shell hostname)
url  = http://$(host):$(port)

url:
	@echo "$(url)"
