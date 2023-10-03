
boot_to_bios() {
    ask "Reboot to BIOS?" &&
    systemctl reboot --firmware-setup
}

windows_boot_entry() {
    efibootmgr -v | grep -o ".*Windows Boot Manager"
}

boot_to_windows_warning() {
    echo
    echo "WARNING"
    echo "======="
    echo "If fastboot is enabled and you boot to Windows,"
    echo "Windows may change your boot order to always start Windows first."
    echo
}

boot_to_windows() {
    local bootentry bootid
    bootentry=$(windows_boot_entry) &&
    bootid=$(echo "$bootentry" | grep -oE "Boot[0-9A-Z]+" | sed s/Boot//)
    if test -z "$bootid"
    then err "could not find boot entry"; return false
    fi

    boot_to_windows_warning

    ask "Reboot to '$bootentry' (bootid=$bootid)?" &&
    sudo efibootmgr --bootnext "$bootid" &&
    sudo reboot
}

test_boot() {
    local wbe
    boot_to_windows_warning | grep -q WARN &&
    wbe=$(windows_boot_entry) &&
    if test -n "$wbe"; then
        (echo "$wbe" | grep -i win || err "wbe != win1") &&
        (echo "N" | boot_to_windows || true) | grep -q WARN
    fi
}
