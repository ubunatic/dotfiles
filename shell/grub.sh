
grub_boot_entry() {
    local grubno
    grubno="$1"
    grub_boot_entries | awk -v num="$grubno" '$1 == num { $1=""; print substr($0, 2) }'
}

grub_boot_entries() {
    sudo awk -v count=1 -F\' '/menuentry / {count++; print count-1 " " $2}' /boot/grub/grub.cfg
}

boot_to_grub_entry() {
    local grubno entry

    grubno="$1"

    if test -z "$grubno"; then
        grub_boot_entries

        prompt "Chose grub item number to boot"
        read grubno
        if test -z "$grubno"
        then err "grub item number not set"; return 1
        fi
    fi

    entry=$(grub_boot_entry "$grubno")
    if test -z "$entry"
    then err "grub entry not found for grub item: $grubno"; return 1
    fi

    if echo "$entry" | grep -q -i windows; then
        boot_to_windows_warning
    fi

    ask "boot entry '$entry'?" &&
    sudo grub-reboot "$grubno" &&
    sudo reboot
}

test_grub() {
    # TODO: find a way to get entries w/o sudo
    #       then test them here
    true
}