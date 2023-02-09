
boot_to_bios() {
    ask "Reboot to BIOS?" &&
    systemctl reboot --firmware-setup
}

windows_boot_entry() {
    efibootmgr -v | grep -o ".*Windows Boot Manager"
}

boot_to_windows() {
    local bootentry=$(windows_boot_entry) &&
    local bootid=$(echo "$bootentry" | grep -oE "Boot[0-9A-Z]+" | sed s/Boot//)
    if test -z "$bootentry"
    then err "could not find boot entry"; return false
    fi

    echo
    echo "WARNING"
    echo "======="
    echo "If fastboot is enabled and you boot to Windows,"
    echo "Windows may change your boot order to always start Windows frist."
    echo

    ask "Reboot to '$bootentry' (bootid=$bootid)?" &&
    sudo efibootmgr --bootnext "$bootid" &&
    sudo reboot
}
