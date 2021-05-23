#!/bin/sh

git_tag_contains() {
    [ $# -gt 0 ] || return 1
    git tag --contains "$1" 2>&1 | head -n 1
}

git_current_branch() {
  ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  [ -n "$ref" ] && printf "%s" "${ref#refs/heads/} "
}