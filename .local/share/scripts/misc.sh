#!/bin/sh

reload() {
    [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" && clear
}

center() {
    [ "$TERM" = "dumb" ] && TERM="ansi"

    termwidth=
    if [ -n "$TERM" ] && ! [ "$TERM" = "dumb" ]; then
        TERM_COLS="$(tput cols)"
    else
        TERM_COLS="$(tput cols -T ansi)"
    fi

    padding="$(printf '%0.1s' ={1..500})"
    printf "%*.*s %s %*.*s\n"        \
        0                            \
        "$(((termwidth-2-${#1})/2))" \
        "$padding"                   \
        "$1"                         \
        0                            \
        "$(((termwidth-1-${#1})/2))" \
        "$padding"
}