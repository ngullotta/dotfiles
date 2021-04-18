#!/bin/sh

send_key() {
    class="$1" && shift
    xdotool search --class "$class" key "$@"
}