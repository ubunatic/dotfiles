# Makefile for MicroPython projects using mpremote
# This Makefile will run on the bridge host (RPi4)
# which is connected to the MicroPython device (Raspberry Pi Pico)

.PHONY: ⚙️

PATH  := ${HOME}/.local/bin:${PATH}
SHELL := PATH=$(PATH) bash -o pipefail -o errexit
export PATH

# Default target, executed when `make` is run without arguments
all: help ## Upload files and run the application

install: ⚙️  ## Install the application
	@echo "Installing remote management tools"
	sudo apt install python3-serial pipx
	pipx ensurepath
	pipx install mpremote

# find sdX1 device that is a Pico
lsblk  = lsblk --json -o NAME,LABEL | jq -r ".blockdevices[].children[]"
label  = RPI-RP2
sdx   := $(shell $(lsblk) | jq -r 'select(.label == "$(label)") | .name')

# (re)mount as read-write with user permissions
# uid: the user ID of the current user
# gid: the group ID of the current user
# umask: set permissions to allow read/write for all users
# rw: mount the filesystem as read-write
mount_options = uid=$(shell id -u),gid=$(shell id -g),umask=0000,rw

mount: ⚙️  ## Mount the device
	@echo "Mounting device /dev/$(sdx) to /media/$(label)..."
	test -n "$(sdx)"      # check if a device was found
	ls -la "/dev/${sdx}"  # check if device exists
	sudo mkdir -p /media/$(label)
	sudo chmod 777 /media/$(label) || true
	sudo umount "/dev/$(sdx)" || true
	sudo mount "/dev/$(sdx)" "/media/$(label)" -o $(mount_options) || true
	sudo tree /media/$(label)
	sudo ls -la /media/$(label)
	cat /media/$(label)/INFO_UF2.TXT
	touch /media/$(label)/dummy.txt
	rm -f /media/$(label)/dummy.txt || true
	@echo "✅ Device mounted writable at /media/$(label)."

umount: ⚙️  ## Unmount the device
	@echo "Unmounting device /dev/$(sdx) from /media/$(label)..."
	@if sudo umount "/dev/$(sdx)" && \
	    sudo rmdir /media/$(label); \
	 then echo "✅ Device unmounted."; \
	 else echo "⚠️ Failed to unmount device."; \
	 fi

upgrade: ⚙️ mount  ## Install MicroPython formware on the device (must be in boot mode)
	@echo "Installing MicroPython firmware on the device..."
	cp rp2-pico-latest.uf2 "/media/$(label)/" && sync
	@echo "✅ Firmware installed in /media/$(label)"

update: ⚙️  ## Upload source files to the device (must be in FS mode)
	@echo "Uploading files to device using mpremote..."
	mpremote cp -r main.py lib :/
	@echo "✅ Files copied to MP device."

info: ⚙️  ## Show information about the environment
	@echo "Environment Information:"
	@echo "mpremote: $(shell mpremote --version)"
	@echo "Python: $(shell python3 --version)"
	@echo "pipx: $(shell pipx --version)"
	@echo "pipx packages: $(shell pipx list | grep -E 'mpremote|micropython' || true)"
	@echo ----
	@echo "Serial Devices: $(shell mpremote devs)"
	@echo "Serial Files: $(shell mpremote ls)"
	@echo ----
	@echo "USB Devices:"
	@lsusb
	@echo ----
	@echo "Mounted filesystems:"
	@mount | grep -E 'on /dev/|type vfat|type ext4'
	@echo ----
	@echo "Mount point: '/media/$(label)'"
	@echo "Device: '$(sdx)'"
	@echo "Mount options: $(mount_options)"
	@echo ----

run: ⚙️ reset  ## Alias for reset, which will run main.py on the board

reset: ⚙️  ## Soft-reset the device
	mpremote reset

repl: ⚙️  ## Enter the REPL on the device
	mpremote repl

ls: ⚙️  ## List files on the device
	# mounted files:
	@sudo tree /media/$(label) 2> /dev/null || true
	@echo
	# mpremote files:
	@mpremote ls 2> /dev/null
	# mpremote lib files:
	@mpremote ls lib 2> /dev/null
	@echo

rm: ⚙️  ## Remove source files from the device
	@echo "Removing files from device..."
	mpremote rm -rf main.py lib || true

clean: ⚙️ rm ## Alias for rm

help: ⚙️  ## Show this help message
	@awk ' \
		BEGIN                 { FS=":.*?## "; print  "Usage: make [target]\n\nTargets:" } \
		/^[a-zA-Z_-]+:.*?## / { printf "   \033[36m%-10s\033[0m %s\n", $$1, $$2 } \
	' $(MAKEFILE_LIST)
