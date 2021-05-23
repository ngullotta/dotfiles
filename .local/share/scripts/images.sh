#!/bin/sh

rotate() {
    which convert > "/dev/null" 2>&1 || return 1

    files=""
    for obj in "$@"; do
        [ -f "$obj" ] && file "$obj" \
            | grep -qE 'image|bitmap' \
            && identify "$obj" > "/dev/null" 2>&1 \
            && [ -z "$files" ] \
            && files="$obj\n" \
            || files="$files$obj\n"

        # One of these args may be +/- degrees, look for it now
        echo "$obj" | grep -E "^[+-]?[0-9]+([.][0-9]+)?$" > /dev/null 2>&1 \
            && [ -z "$const" ] \
            && const="$obj"
    done

    # We may want to just oneshot the entire directory
    if [ -z "$files" ]; then
        for obj in ./*.*; do
            [ -f "$obj" ] && file "$obj" \
                | grep -qE 'image|bitmap' \
                && identify "$obj" > "/dev/null" 2>&1 \
                && [ -z "$files" ] \
                && files="$obj\n" \
                || files="$files$obj\n"
        done
    fi

    echo "$files" | \
    while IFS= read -r file; do
        deg="${const:-90}"
        [ -n "$file" ] && [ -f "$file" ] \
            && convert "$file" -rotate "$deg" "$file" \
            && echo "Rotated $(basename "$file") by $deg°"
    done
}