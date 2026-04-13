
gen_pass() {
    # Default segment length is 4 if no argument is provided
    local len=${1:-4}

    # Generate 4 segments of the specified length
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w "$len" | head -n 4 | paste -sd '-' -
}