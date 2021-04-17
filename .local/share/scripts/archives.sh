#!/bin/sh

extract() {
    for n in "$@"; do
        if ! [ -f "$n" ]; then
            2&> echo "'$n' - file does not exist" && return 1
        fi

        case "${n%,}" in
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                tar xvf "$n"
            ;;
            *.lzma)
                unlzma ./"$n"
                ;;
            *.bz2)
                bunzip2 ./"$n"
                ;;
            *.cbr|*.rar)
                unrar x -ad ./"$n"
                ;;
            *.gz)
                gunzip ./"$n"
                ;;
            *.cbz|*.epub|*.zip)
                unzip ./"$n"
                ;;
            *.z)
                uncompress ./"$n"
                ;;
            *.7z|*.apk|*.deb|*.dmg|*.iso|*.pkg|*.rpm)
                7z x ./"$n"
                ;;
            *)
                echo "Unknown archive method for '$n'"
                return 1
                ;;
        esac
    done
}