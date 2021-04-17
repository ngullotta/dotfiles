#!/bin/zsh

# @ToDo -> Make this POSIX compliant

rotate() {
    which convert > "/dev/null" 2>&1 || return 1
    files=()
    const=
    for obj in "$@"; do
        [ -f "$obj" ] && file "$obj" \
            | grep -qE 'image|bitmap' \
            && identify "$obj" > "/dev/null" 2>&1 \
            && files+=("$obj")

        [[ "$obj" =~ "^[+-]?[0-9]+([.][0-9]+)?$" ]] \
            && [ -z "$const" ] && const="$obj"
    done

    for file in $files; do
        deg="${const:-90}"
        convert "$file" -rotate "$deg" "$file"
        echo "Rotated $(basename $file) by $deg°"
    done
}