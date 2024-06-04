#!/usr/bin/env bash

# Swift SDK checker for finding SDK locations and IDE settings.
swift-check() {(
    # run the script in a subshell to avoid polluting the current shell

    red()  { echo -e "\033[0;31m$*\033[0m"; }
    bold() { echo -e "\033[1m$*\033[0m"; }
    warn() { echo -n "$(red warning): " >/dev/stderr; echo -e "$@" >/dev/stderr; }
    info() { echo -n "$(bold info): "   >/dev/stderr; echo -e "$@" >/dev/stderr; }

    # shellcheck disable=SC2034
    {
        # Swift SDKs root path
        sdk_prefix=${SWIFT_PREFIX:-$(find /opt/homebrew/Cellar/swift/* | head -n 1)}

        # Swift SDK dirs and build tools (run find_tools to set them)
        xctoolchain=""
        swift_path=""
        swift_runtime_path=""
        swift=""
        swiftc=""
        sourcekit_lsp=""
        LLDB=""
    }

    # find all Swift SDKs dirs and build tools
    find_tools() {
        xctoolchain="$(ls -d "$sdk_prefix"/Swift-*.xctoolchain)"
        swift_path="$xctoolchain/usr/bin"
        swift_runtime_path="$xctoolchain/usr/lib/swift/macosx"

        if test -d "$sdk_prefix"
        then info "Swift SDK: $sdk_prefix"
        else warn "Swift SDK not found at: /opt/homebrew/Cellar/swift/*"; return 1
        fi

        if test -d "$xctoolchain"
        then info "Swift Toolchain: $xctoolchain"
        else warn "Swift Toolchain not found at: $sdk_prefix"; return 1
        fi

        if test -d "$swift_path"
        then info "Swift Path: $swift_path"
        else warn "Swift Path not found at: $xctoolchain"; return 1
        fi

        if test -d "$swift_runtime_path"
        then info "Swift Runtime Path: $swift_runtime_path"
        else warn "Swift Runtime Path not found at: $xctoolchain"; return 1
        fi

        local tool var
        for b in swift swiftc sourcekit-lsp LLDB; do
            var="${b//-/_}"
            if tool="$(find "$sdk_prefix" -name $b 2>/dev/null | head -n 1)" &&
               test -n "$tool" && test -n "$var" &&  # ensure key and a value are not empty
               eval "$var='$tool'"               &&  # set the variable
               test -n "$(eval echo "\$$var")"       # check if the new var is empty
            then info "variable '$b' set to $tool"
            else warn "Failed to set global var: $b"; return 1
            fi
        done
    }

    vscode_settings() {
        local f="$HOME/Library/Application Support/Code/User/settings.json"
        info "\nCurrent VSCode Settings:\n"
        grep -E '^[ ]*"swift.*"' "$f" >/dev/stderr
        find_tools 1>/dev/null 2>/dev/null
        info "\nSwift SDKs and Build Tools:\n"
        for v in sdk_prefix swift_path swift_runtime_path xctoolchain swift swiftc sourcekit_lsp LLDB; do
            printf "    %-20s ${!v}\n" "$v" >/dev/stderr
        done
        info "\nAdd the following to your VSCode settings.json:"
        cat <<-EOF
// Swift SDKs and Build Tools
// ==========================
"swift.runtimePath": "$swift_runtime_path",
"swift.path": "$swift_path",
"lldb.library": "$LLDB",
"lldb.launch.expressions": "native",
EOF
    }

    usage () {
        cat <<-EOF
Usage: $0 COMMAND

Commands:
    help    Show this help message (aliases: -h, --help)
    tools   Find all Swift SDKs dirs and build tools
    code    Show VSCode settings for Swift

Environment Variables:
    SWIFT_PREFIX  Sets the path to Swift SDKs (value='$SWIFT_PREFIX'), leave empty to auto-detect.

EOF
    }

    if test "$#" -eq 0
    then usage
    fi

    case "$1" in
        tools|find)     find_tools ;;
        help|-h|--help) usage; exit 0 ;;
        code|vscode)    vscode_settings ;;
        *) warn "unknown command: $1"; exit 1 ;;
    esac

)}
