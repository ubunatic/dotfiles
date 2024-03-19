#!/usr/bin/env bash

# Clamshell Behavior
# ==================
#
# Mac M1: Lid Closed + Monitor Connected
# clamshell yes: Yes
# clamshell dp:  1
# -> pmset sleepnow
#
# Mac M1: Lid Open + Monitor Connected
# clamshell yes: No
# clamshell dp:  4
# -> noop
#
# Mac M1: Lid Open + Monitor Disconnected
# clamshell yes: No
# clamshell dp:  1
# -> noop

# clamshelld starts a daemon that manages sleep behavior when the lid is closed.
clamshelld() { clamshell "$@" daemon; }

# clamshell manages sleep behavior when the lid is closed.
# See `clamshell help` for more information.
clamshell() {(
    # Run everything in a subshell to avoid polluting the environment.
    # This also allows safe use of exec to replace the current shell with clamshelld

    clamshell-help() { cat <<-EOF
Usage: clamshell [OPTION] [COMMAND]

Options:
    --debug  -d    Enable debug mode
    --help   -h    Display this help

Commands:
    help                h        Display this help
    check               c        Check if clamshell mode is active (alias: yes|y, returns 0 if yes)
    has-display         disp     Check if the external display is connected (returns 0 if yes)
    has-legacy-display  ldisp    Check if the legacy display is awake (returns 0 if yes)
    device-proxy        dp       Check the number of DCPDPDeviceProxy
    sleep               sl       Force sleep if clamshell mode is active
    sleeping            sln      Check if the system is sleeping (returns 0 if yes)
    awake               aw       Check if the system is awake (returns 0 if yes)
    summary             sm       Display a summary of all checks
    complete            co       Print the zsh completion function

Daemon Commands:
    daemon     dm    Runs the sleep command every second (also see clamshelld)
    install    in    Install a launchd service to run clamshelld
    uninstall  un    Uninstall the launchd service
    status     st    Check the status of the launchd service
    load       ld    Start the launchd service (alias: start)
    unload     ul    Stop the launchd service (alias: stop)

Developer Commands:
    selftest   self  Run a selftest to check if all commands work as expected
    log        log   Tail the clamshelld log file
    binary     bin   Compile the clamshell script to a clamshelld binary
    assertions asn   Show the pmset assertions that prevent sleep

EOF
}

    # Launchd service variables
    clamshelld_prefix="$HOME/Library/Clamshell/1.0.0"
    clamshelld_bin="$clamshelld_prefix/bin/clamshelld"
    clamshelld_service="com.github.ubunatic.clamshell.plist"
    clamshelld_plist="$HOME/Library/LaunchAgents/$clamshelld_service"
    clamshelld_log="$HOME/Library/Logs/clamshell.log"

    # main function to parse flags and run commands
    clamshell-main() {
        # parse flags
        local flag
        for flag in "$@"
        do case "$flag" in
            -d|--debug)    export CLAMSHELL_DEBUG=1 ;;
            -h|--help|h*)  clamshell-help; return 0 ;;
            -*)            echo "Unknown option: $1"; return 1 ;;
        esac
        done

        # run commands
        local cmd
        for cmd in "$@"
        do case "$cmd" in
            -*)            ;;  # ignore flags
            y*|c|ch*)      clamshell-yes ;;
            n|no*)         clamshell-no ;;
            di*|has-d*)    clamshell-has-display ;;
            ldi*|has-l*)   clamshell-has-legacy ;;
            dp|de*)        clamshell-proxy-num ;;
            sleepi*|sln)   clamshell-sleeping ;;
            sl*)           clamshell-sleep ;;
            aw*)           clamshell-awake ;;
            su*)           clamshell-summary ;;
            da*)           exec -a clamshelld clamshell-daemon | tee -i -a "$clamshelld_log" ;;
            bin*|compi*)   clamshell-binary ;;
            co*)           clamshell-complete ;;
            in*)           clamshell-install ;;
            un|uni*)       clamshell-uninstall ;;
            st|stat*)      clamshell-status ;;
            log*)          clamshell-log ;;
            as*)           clamshell-assertions ;;
            ld|lo*|start)  clamshell-ctl load ;;
            ul|unl*|stop)  clamshell-ctl unload ;;
            self*)         clamshell-selftest ;;
            *)             echo "Unknown command: $1"; return 1 ;;
        esac
        done
    }

    # clamshell-daemon runs a loop to detect clamshell mode and initiate sleep
    # shellcheck disable=SC2317
    clamshell-daemon() {
        local t0=0 elapsed=0 n=0 sleeping_since=0 sleeping_for=0 awake_since=0 awake_for=0
        t0="$(date +%s)"
        logger "Starting clamshell daemon"
        trap "logger 'Clamshell daemon stopped'; exit 0" INT TERM
        while sleep 1; do
            # Log Rotation
            # ============
            (( n++ ))
            (( elapsed = $(date +%s) - t0 ))
            if (( elapsed > 86400 )); then
                t0="$(date +%s)"
                logger "clamshell daemon running for 24h, saving log as $clamshelld_log.old"
                cp -f "$clamshelld_log" "$clamshelld_log.old"
                echo -n > "$clamshelld_log"
                logger "log rotated after 24h, see $clamshelld_log.old for previous log"
            fi

            # Keep Sleeping
            # =============
            if clamshell-sleeping; then
                (( sleeping_for = $(date +%s) - sleeping_since ))
                if (( n % 600 == 0 )); then
                    # log every 10 minutes
                    logger "clamshell is sleeping for $sleeping_for Seconds"
                fi
                sleep 10
                continue
            fi

            # Try to Sleep
            # ============
            if clamshell-sleep; then
                sleeping_since="$(date +%s)"
                awake_since=0
                logger "clamshell sleep initated, waiting 5s to reach sleep state"
                sleep 5
                continue
            fi

            # Awaking
            # =======
            if (( awake_since == 0 )); then
                awake_since="$(date +%s)"
                logger "clamshell became awake"
                continue
            fi

            # Stay Awake
            # ==========
            (( awake_for = $(date +%s) - awake_since ))
            if (( n % 600 == 0 )); then
                # log every 10 minutes
                logger "clamshell is awake for $awake_for Seconds"
                continue
            fi
        done
    }

    # shellcheck disable=SC2317,SC2207
    # bash/zsh command completion
    _clamshell() {
        local commands
        commands="$(clamshell help | grep '^    .*' | tr -s ' ' | cut -d' ' -f2 | sort -u)"
        COMPREPLY=($(compgen -W "$commands" -- "${COMP_WORDS[COMP_CWORD]}"))
    }

    clamshell-complete() {
        case $- in *i*)
            type -f _clamshell > /dev/null &&
            echo "complete -F _clamshell clamshell"
            return 0
        esac
        echo "# no completion function found"
    }

    clamshell-binary() {
        mkdir -p "$clamshelld_prefix/bin"
        echo "Compiling clamshell script to clamshelld binary in prefix $clamshelld_prefix"
        (
            echo "#!/usr/bin/env zsh" &&
            which clamshell &&
            echo 'clamshell daemon'
        ) > "$clamshelld_bin" &&
        chmod +x "$clamshelld_bin" &&
        echo "clamshelld binary created at $clamshelld_bin"
    }

    # man pmset:
    #      displaysleep             display sleep timer; replaces 'dim' argument in 10.4 (value in minutes, or 0 to disable)
    #      disksleep                disk spindown timer; replaces 'spindown' argument in 10.4 (value in minutes, or 0 to disable)
    #      sleep                    system sleep timer (value in minutes, or 0 to disable)
    #      womp                     wake on ethernet magic packet (value = 0/1). Same as "Wake for network access" in System Settings.
    #      ring                     wake on modem ring (value = 0/1)
    #      powernap                 enable/disable Power Nap on supported machines (value = 0/1)
    #      proximitywake            On supported systems, this option controls system wake from sleep based on proximity of devices using same iCloud id. (value = 0/1)
    #      autorestart              automatic restart on power loss (value = 0/1)
    #      lidwake                  wake the machine when the laptop lid (or clamshell) is opened (value = 0/1)
    #      acwake                   wake the machine when power source (AC/battery) is changed (value = 0/1)
    #      lessbright               slightly turn down display brightness when switching to this power source (value = 0/1)
    #      halfdim                  display sleep will use an intermediate half-brightness state between full brightness and fully off  (value = 0/1)
    #      sms                      use Sudden Motion Sensor to park disk heads on sudden changes in G force (value = 0/1)
    #      hibernatemode            change hibernation mode. Please use caution. (value = integer)
    #      hibernatefile            change hibernation image file location. Image may only be located on the root volume. Please use caution. (value = path)
    #      ttyskeepawake            prevent idle system sleep when any tty (e.g. remote login session) is 'active'. A tty is 'inactive' only when its idle time exceeds the system sleep timer. (value = 0/1)
    #      networkoversleep         this setting affects how OS X networking presents shared network services during system sleep. This setting is not used by all platforms; changing its value is unsupported.
    #      destroyfvkeyonstandby    Destroy File Vault Key when going to standby mode. By default File vault keys are retained even when system goes to standby. If the keys are destroyed, user will be prompted to enter the password while coming out of standby mode.(value: 1 - Destroy, 0 - Retain)

    # Testing pmset changes:
    # sudo pmset -a tcpkeepalive 0   # changes setting, shows a warning
    # sudo pmset -a ttyskeepawake 0  # changes setting
    # sudo pmset -a acwake 0         # has no effect
    # sudo pmset -a sleep 1          # does not change the exclusions for powerd  and bluetoothd
    # sudo pmset -a ring 0           # has no effect

    # pmset -g before:                                                   # pmset -g after:
    #  System-wide power settings:                                       #  System-wide power settings:
    #   SleepDisabled          0                                         #   SleepDisabled          0
    #   DestroyFVKeyOnStandby          1                                 #   DestroyFVKeyOnStandby          1
    #  Currently in use:                                                 #  Currently in use:
    #   standby              1                                           #   standby              1
    #   Sleep On Power Button 1                                          #   Sleep On Power Button 1
    #   hibernatefile        /var/vm/sleepimage                          #   hibernatefile        /var/vm/sleepimage
    #   powernap             1                                           #   powernap             1
    #   networkoversleep     0                                           #   networkoversleep     0
    #   disksleep            10                                          #   disksleep            10
    #   sleep                1 (sleep prevented by powerd, bluetoothd)   #   sleep                1 (sleep prevented by powerd, bluetoothd)
    #   hibernatemode        3                                           #   hibernatemode        3
    #   ttyskeepawake        1                                           #   ttyskeepawake        0
    #   displaysleep         90                                          #   displaysleep         90
    #   tcpkeepalive         1                                           #   tcpkeepalive         0
    #   lowpowermode         0                                           #   lowpowermode         0
    #   womp                 0                                           #   womp                 0

    clamshell-yes()         { ioreg -r -k AppleClamshellState | grep AppleClamshellState | grep -q "Yes"; }
    clamshell-no()          { ! clamshell-yes; }
    clamshell-log()         { tail -F "$clamshelld_log"; }
    clamshell-sleeping()    { pmset -g assertions | grep -qE '^\s*PreventUserIdleSystemSleep\s*0'; }
    clamshell-awake()       { pmset -g assertions | grep -qE '^\s*PreventUserIdleSystemSleep\s*1'; }
    clamshell-assertions()  { pmset -g assertions | grep -E  'PreventUserIdleSystemSleep'; }
    clamshell-proxy-num()   { pmset -g powerstate | grep -c DCPDPDeviceProxy; }
    clamshell-has-display() { test "$(clamshell-proxy-num)" -lt 4; }
    clamshell-has-legacy() {
        pmset -g powerstate | grep AppleDisplay | grep -q USEABLE &&
        pmset -g powerstate | grep IODisplayWrangler | grep -q USEABLE
    }

    # clamshell-summary displays a summary of all checks
    clamshell-summary() {
        echo "ARCH: $(uname -m)"
        echo "clamshell-yes:         $(clamshell-yes         && echo Yes || echo No)"
        echo "clamshell-has-display: $(clamshell-has-display && echo Yes || echo No)"
        echo "clamshell-has-legacy:  $(clamshell-has-legacy  && echo Yes || echo No)"
        echo "clamshell-sleeping:    $(clamshell-sleeping    && echo Yes || echo No)"
        echo "clamshell-proxy-num:   $(clamshell-proxy-num)"
        echo "clamshell-sleep:       $(CLAMSHELL_DEBUG=1 clamshell-sleep)"
    }

    logger-n()     { echo -n -e "\r$(date '+%Y-%m-%d %H:%M:%S'): $*, output="; }  # log without newline
    logger()       { echo    -e "\r$(date '+%Y-%m-%d %H:%M:%S'): $*"; }           # log with newline

    # shellcheck disable=SC2317
    echo-pmset() { echo "/usr/bin/pmset $*"; }

    # clamshell-sleep initiates sleep if clamshell mode is active and returns 0 on success.
    # It does not wait for sleep to complete or for clamshell mode to change. Use clamshell-daemon for that.
    clamshell-sleep() {
        local pmset code
        if test -n "$CLAMSHELL_DEBUG"
        then pmset="echo-pmset"
        else pmset="/usr/bin/pmset"
        fi

        if clamshell-yes; then
            code=0
            if clamshell-has-display; then
                logger-n "clamshell detected, display found, initating sleep cmd=$pmset arg=sleepnow"
                $pmset sleepnow
                code=$?
            elif clamshell-has-legacy; then
                logger-n "clamshell detected, legacy display found, initating sleep cmd=$pmset arg=sleepnow"
                $pmset sleepnow
                code=$?
            elif test -n "$CLAMSHELL_DEBUG"; then
                # echo a noop command to stdout as sleep command output for testing
                echo noop "(lid open or display asleep)"
            fi

            if test $code -gt 0; then
                logger "Failed to sleep, $pmset sleepnow exited with code=$code"
            fi
            return $code

        elif test -n "$CLAMSHELL_DEBUG"; then
            echo noop "(no clamshell)"
        fi
        return 1
    }

    # clamshell-install installs a Launchd service to run clamshelld in the background.
    clamshell-install() {
        local svc="$clamshelld_service" dst="$clamshelld_plist"

        if ! clamshell-binary
        then echo "Failed to create clamshelld binary"; return 1
        fi

        # request permission to create the launchd service
        if touch "$dst" 2> /dev/null; then
            echo "Created empty plist file $dst"
        else
            echo "Requesting permission to create launchd service $svc at $dst"
            if sudo touch "$dst" && sudo chown "$USER" "$dst"
            then echo "Created empty plist file $dst"
            else echo "Failed to create empty plist file $dst"; return 1
            fi
        fi

        # create a launchd plist file
        cat > "$dst" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$svc</string>
    <key>ProgramArguments</key>
    <array>
        <string>$clamshelld_bin</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
        local code=$?
        if test "$code" -gt 0; then
            echo "Failed to install launchd service $svc at $dst err=$code"
            return 1
        fi

        echo "Launchd service $svc installed at $dst using binary '$clamshelld_bin'"
        echo "Stopping clamshelld instances and reloading clamshelld service"
        if pkill clamshelld 2> /dev/null
        then echo "clamshelld process stopped"
        else echo "no clamshelld instances running"
        fi
        clamshell-ctl unload
        clamshell-ctl load
    }

    # clamshell-uninstall removes the Launchd service that runs clamshelld in the background.
    clamshell-uninstall() {
        local svc="$clamshelld_service" dst="$clamshelld_plist"

        if test -e "$dst"; then
            clamshell-ctl unload
            rm -f "$dst" 2> /dev/null || sudo rm -f "$dst" 2> /dev/null
            echo "Launchd service $svc uninstalled from $dst"
        else
            echo "Launchd service $svc not installed from $dst"
        fi
    }

    # clamshell-ctl runs a launchctl command (load|unload) with the Launchd plist file
    clamshell-ctl() {
        local code=1 svc="$clamshelld_service" dst="$clamshelld_plist"
        if test -e "$dst"
        then
            launchctl "$1" -w "$dst"; code=$?
            if test "$code" -eq 0
            then echo "Launchd service $1: OK"
            else echo "Launchd service $1: FAILED"
            fi
        else
            echo "Launchd service $svc not installed"
        fi
        return $code
    }

    clamshell-status() {
        local code svc="$clamshelld_service" dst="$clamshelld_plist"
        printf "\nLaunchd Status:\n";      launchctl list "$svc"; code=$?
        printf "\nLogfile:\n";             tail -n 10 "$clamshelld_log"
        printf "\nLaunchd PList File:\n";  test -e "$dst" && echo "found at $dst" || echo "not found at $dst"
        printf "\nPgrep clamshelld:\n";    pgrep clamshelld || echo "no clamshelld process found (try sudo pgrep)"
        printf "\nLaunchd Status Code: %s\n" $code
        return $code
    }

    # shellcheck disable=SC2317
    clamshell-selftest() {(
        exec 2>&1  # redirect stderr to stdout for error checking

        local err=""
        err()       { err="$err\n$*"; }
        noerr()     { wc -l | grep -qE '^\s*0' || err "$@"; }
        nobasherr() { grep -E '^(bash:|clamshell*:)' && err "$@"; }

        clamshell-yes || clamshell-no  || err "clamshell yes/no failed"
        clamshell-complete  >/dev/null || err "clamshell complete failed"
        clamshell-proxy-num >/dev/null || err "clamshell proxy-num failed"
        clamshell-awake                || err "clamshell awake failed"
        ! clamshell-sleeping           || err "clamshell sleeping failed"
        # commands without output should not show any errors
        # do not run these tests in clamshell mode
        clamshell-has-display | noerr "clamshell has-display failed"
        clamshell-has-legacy  | noerr "clamshell has-legacy failed"
        clamshell-sleep       | noerr "clamshell sleep failed"
        # commands with output should not show any bash errors
        clamshell-summary          | nobasherr "clamshell summary failed"
        clamshell-help             | nobasherr "clamshell help failed"
        clamshell-status           | nobasherr "clamshell status failed"
        clamshell-ctl load         | nobasherr "clamshell ctl load failed"
        clamshell-ctl unload       | nobasherr "clamshell ctl unload failed"

        if test -z "$err"
        then echo "clamshell selftest: OK"
        else echo -e "$err"; echo "clamshell selftest: FAILED"
        fi
    )}

    clamshell-main "$@"
)}

if test "$(uname -s)" = "Darwin"; then
    eval "$(clamshell complete)"
fi
