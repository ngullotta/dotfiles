#!/bin/sh

reload() {
    # shellcheck source=/dev/null
    [ -f "$HOME/.zshrc" ] && . "$HOME/.zshrc" && clear
}

center() {
    [ "$TERM" = "dumb" ] && TERM="ansi"

    termwidth=
    if [ -n "$TERM" ] && ! [ "$TERM" = "dumb" ]; then
        termwidth="$(tput cols)"
    else
        termwidth="$(tput cols -T ansi)"
    fi

    i=1
    while [ $i -le 500 ]; do
        padding="$padding$(printf '%-.1s' =$i)"
        i=$((i+1))
    done

    printf "%*.*s %s %*.*s\n"        \
        0                            \
        "$(((termwidth-2-${#1})/2))" \
        "$padding"                   \
        "$1"                         \
        0                            \
        "$(((termwidth-1-${#1})/2))" \
        "$padding"
}