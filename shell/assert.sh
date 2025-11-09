
# assert is a simple assertion function for shell script testing
# Usage 1: some_command | assert <assertion_type> <expected_value...>
# Usage 2: some_command || assert fail <optional_message>
assert() {
     local assertion got exp code="0" err
     assertion="$1"; shift
     case $assertion in
     (fail)     err="test failed: $*" ;;
     (ok)       ;;
     (contains) grep -q  "$*"  || err="expected output to contain: '$*'" ;;
     (line)     grep -qx "$*"  || err="expected output to contain line: '$*'" ;;
     (*all)
          local missing
          if got="$(cat)" && test -n "$got"
          then dbg "Checking that output contains all of: $*"
               dbg "Output to check: $got"
               for exp in "$@"
               do if echo "$got" | grep -q "$exp"
               then dbg "Output contains expected string: '$exp'"
               else dbg "Output does not contain expected string: '$exp'"
                    missing="$missing '$exp'"
               fi
               done
          else err="no output to check for contains all"
          fi
          if test -z "$missing"
          then dbg "Output contains all expected strings"
          else err="expected output to contain:$missing"
          fi
          ;;
     (equals)
          if exp="$*" && got="$(cat)" && test "$got" = "$exp"
          then dbg "Output equals expected string: '$exp'"
          else err="expected output to equal: '$exp', got: '$got'"
          fi ;;
     (*)  err="unknown assertion type: '$assertion'" ;;
     esac || code="$?"
     if test -z "$err" && test "$code" -eq 0
     then log "Assertion succeeded: $assertion '$*'"
     else err "Assertion failed: $err"
          if test "$code" -eq 0
          then code="1";  # set error code if not already set
          fi
     fi
     return $code
}