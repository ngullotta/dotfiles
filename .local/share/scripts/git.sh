#!/bin/sh

git_tag_contains() {
    [ $# -gt 0 ] || return 1
    git tag --contains "$1" 2>&1 | head -n 1
}

git_current_branch() {
    ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
    rv=$?
    if ! [ $rv = 0 ]; then
        if [ $rv = 128 ]; then
            return 1
        fi
        ref=$(command git rev-parse --short HEAD 2> /dev/null)
    fi
    echo -n "${ref#refs/heads/} "
}