
if ! command -v efibootmgr 1>/dev/null 2>/dev/null
then EFIBOOT_MOCK="${EFIBOOT_MOCK:-1}"
fi

# Boots to the firmware setup (BIOS).
efiboot_to_bios() {
    ask "Reboot to BIOS?" &&
    if test -z "$EFIBOOT_MOCK"
    then systemctl reboot --firmware-setup
    else echo "skipping reboot to firmware"
    fi
}

# Find the windows boot entry.
efiboot_windows_entry() {
    if test -z "$EFIBOOT_MOCK"
    then efibootmgr -v | grep -o ".*Windows Boot Manager"
    else echo "Boot0000* Windows Boot Manager"
    fi
}

# Informs the user about defective windows fastboot behavior.
efiboot_windows_warning() {
    echo
    echo "WARNING"
    echo "======="
    echo "If fastboot is enabled and you boot to Windows,"
    echo "Windows may change your boot order to always start Windows first."
    echo
}

# Finds windows efiboot entry, sets it as next boot entry, then reboots the machine.
efiboot_to_windows() {

    local bootentry bootid
    bootentry=$(efiboot_windows_entry) &&
    bootid=$(echo "$bootentry" | grep -oE "Boot[0-9A-Z]+" | sed s/Boot//)
    if test -z "$bootid"
    then err "could not find boot entry"; return 1
    fi

    efiboot_windows_warning > /dev/stderr

    ask "Reboot to '$bootentry' (bootid=$bootid)?" &&
    if test -z "$EFIBOOT_MOCK"
    then sudo efibootmgr --bootnext "$bootid" && sudo reboot
    else echo "skipping to set next boot entry to $bootid"
    fi
}

dotfiles-testefiboot() {
    (
        ok() { log "OK efiboot_$*"; }
        EFIBOOT_MOCK=1
        efiboot_windows_warning | grep -q WARN                               && ok "windows_warning"  &&
        efiboot_windows_entry   | grep -q Windows                            && ok "windows_entry" &&
        (echo "y" | efiboot_to_windows 2>/dev/null || true) | grep -q Reboot && ok "to_windows" &&
        (echo "y" | efiboot_to_bios                || true) | grep -q Reboot && ok "to_bios"
    )
}
