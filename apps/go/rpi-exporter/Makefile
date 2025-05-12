.PHONY: ⚙️

# env var inputs
RPI_HOST ?= pi4
RPI_USER ?= pi

# local vars for better readability
addr       = $(RPI_USER)@$(RPI_HOST)
query_addr = http://$(RPI_HOST):9101/metrics
upload_dir = /home/$(RPI_USER)/Downloads
run        = ssh -q $(addr)
srcbin     = bin/rpi-exporter
testbin    = bin/rpi-exporter.test
prefix     = /usr/local
name       = rpi-exporter

build: ⚙️
	GOARCH=arm64 GOOS=linux go build   -o "$(srcbin)"  ./cmd/main.go
	GOARCH=arm64 GOOS=linux go test -c -o "$(testbin)" ./collector/...

vars: ⚙️
	# RPI_USER@RPI_HOST:   $(RPI_USER)@$(RPI_HOST)
	# RPI_EXPORTER_PREFIX: $(RPI_EXPORTER_PREFIX)
	# ----
	# addr:       $(addr)
	# query_addr: $(query_addr)
	# upload_dir: $(upload_dir)
	# ----
	# USER: $(USER)
	# HOSTNAME: $(HOSTNAME)

test: ⚙️ build
	go test -v ./...  # local testing

pi-only: ⚙️
	"$(srcbin)" -rpi  # ensure we run on an RPi
	test "$(name)" = "rpi-exporter"  # DEVELOP: do not allow other service names

host-install: ⚙️ pi-only vars
	@echo "Installing $(name) at $(prefix)/bin and /etc/systemd/system"
	mkdir -p "$(prefix)/bin"
	test -e service.ini
	systemctl stop $(name).service 2>/dev/null || true
	cp "$(srcbin)" "$(prefix)/bin/$(name)"
	sed -e 's|ExecStart=.*|ExecStart=$(prefix)/bin/$(name)|g' service.ini > "/etc/systemd/system/$(name).service"
	systemctl daemon-reload
	systemctl enable $(name).service
	systemctl start $(name).service
	curl http://$(shell hostname):9101/metrics

host-uninstall: ⚙️
	@echo "Uninstalling $(name) from /etc/systemd/system"
	systemctl disable $(name).service || true
	systemctl stop $(name).service    || true
	systemctl daemon-reload
	rm -f /etc/systemd/system/$(name).service

upload: ⚙️ build
	@echo "copying binary to $(addr):$(upload_dir)/"
	$(run) mkdir -p "$(upload_dir)"
	$(run) rm -f "$(upload_dir)/$(name)" "$(upload_dir)/$(name).test"
	scp -qp "$(srcbin)"  "$(addr):$(upload_dir)/$(name)"
	scp -qp "$(testbin)" "$(addr):$(upload_dir)/$(name).test"

test-uploads: ⚙️ test upload
	$(run) "$(upload_dir)/$(name)"      -rpi     # ensure we run on a pi
	$(run) "$(upload_dir)/$(name).test" -test.v  # remote testing

install: ⚙️ upload
	$(run) sudo $(upload_dir)/$(name) -install

uninstall: ⚙️ upload
	$(run) sudo $(upload_dir)/$(name) -uninstall

query: ⚙️
	curl $(query_addr)
