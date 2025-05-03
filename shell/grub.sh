if ! command -v grub-reboot 1>/dev/null 2>/dev/null
then GRUBOOT_MOCK="${GRUBOOT_MOCK:-1}"
fi

# Shows the Grub boot entry for a given entry number.
gruboot_entry() {
    local grubno="$1"
    gruboot_entries | awk -v n="$grubno" '$1 == n { $1=""; print substr($0, 2) }'
}

# Warns the user about potential boot entry detection issues.
gruboot_warn() {
    if test "$gruboot_warn_status" != "warned"
    then echo -e "
    WARNING: Detected Grub boot entry numbers may differ from the actual position in the menu!
    The detection of the Grub boot entries is best-effort and will skip advanced and fallback entries.
    gruboot_warn_status=$gruboot_warn_status
    " > /dev/stderr
    fi

    if test -v gruboot_warn_status
    then gruboot_warn_status="warned"
    fi
}

# Lists all main grub boot entries. # The entries are extracted from the
# /boot/grub/grub.cfg shell script, which is a best-effort approach.
gruboot_entries() {
    gruboot_warn
    if test -z "$GRUBOOT_MOCK"
    then sudo awk -v n=1 -F"'|\"" '/menuentry / && !/-advanced|-fallback/ { print n " " $2; n++ }' /boot/grub/grub.cfg
    else echo -e "1 Linux\n2 Windows"
    fi
}

# Boots to a given or selected Grub boot entry.
gruboot_to_entry() {
    local grubno entry
    if ! test -v gruboot_warn_status
    then local gruboot_warn_status
    fi

    grubno="$1"

    if test -z "$grubno"; then
        gruboot_entries

        prompt "Chose grub item number to boot"
        if read -r grubno && test -z "$grubno"
        then err "grub item number not set"; return 1
        fi
    fi

    entry=$(gruboot_entry "$grubno")
    if test -z "$entry"
    then err "grub entry not found for grub item: $grubno"; return 1
    fi

    if echo "$entry" | grep -q -i windows; then
        gruboot_windows_warning > /dev/stderr
    fi

    echo
    ask "Boot to entry: number=$grubno, name='$entry'?" &&
    if test -z "$GRUBOOT_MOCK"
    then sudo grub-reboot "$grubno" && sudo reboot
    else echo "skipping to set next boot entry"
    fi
}

# Informs the user about defective windows fastboot behavior.
gruboot_windows_warning() {
    echo
    echo "WARNING"
    echo "======="
    echo "If fastboot is enabled and you boot to Windows,"
    echo "Windows may change your boot order to always start Windows first."
    echo
}

dotfiles-testgruboot() {
    (
        GRUBOOT_MOCK=1
        gruboot_warn            2>&1 | grep -q "WARN"
        gruboot_windows_warning 2>&1 | grep -q "WARN"
        gruboot_warn_status='warned'
        gruboot_entries | grep -q "Windows"
        gruboot_entry 1 | grep -q "Linux"
        echo "y"       | gruboot_to_entry 1  | grep -q "name='Linux'.* skipping"
        echo -e "1\ny" | gruboot_to_entry    | grep -q "name='Linux'.* skipping"
    )
}
