#!/bin/sh

# Detect package manager
detect_pm() {
    if command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v brew >/dev/null 2>&1; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Install packages based on package manager
install_packages() {
    pm="$1"
    shift
    packages="$*"
    
    case "$pm" in
        pacman)
            # shellcheck disable=SC2086
            sudo pacman -S --needed $packages
            ;;
        dnf)
            # shellcheck disable=SC2086
            sudo dnf install -y $packages
            ;;
        apt)
            # shellcheck disable=SC2086
            sudo apt update && sudo apt install -y $packages
            ;;
        brew)
            # shellcheck disable=SC2086
            brew install $packages
            ;;
        *)
            echo "Unsupported package manager: $pm"
            exit 1
            ;;
    esac
}

# Get package name for specific package manager
get_package_name() {
    generic_name="$1"
    pm="$2"
    
    # Package mappings - format: generic:pacman:dnf:apt:brew
    case "$generic_name" in
        editor) mapping="editor:vim:vim:vim:vim" ;;
        terminal) mapping="terminal:alacritty:alacritty:alacritty:alacritty" ;;
        shell) mapping="shell:zsh:zsh:zsh:zsh" ;;
        git) mapping="git:git:git:git:git" ;;
        curl) mapping="curl:curl:curl:curl:curl" ;;
        tmux) mapping="tmux:tmux:tmux:tmux:tmux" ;;
        ripgrep) mapping="ripgrep:ripgrep:ripgrep:ripgrep:ripgrep" ;;
        fd) mapping="fd:fd:fd-find:fd-find:fd" ;;
        bat) mapping="bat:bat:bat:bat:bat" ;;
        exa) mapping="exa:exa:exa:exa:exa" ;;
        nodejs) mapping="nodejs:nodejs:nodejs:nodejs:node" ;;
        python) mapping="python:python:python3:python3:python3" ;;
        docker) mapping="docker:docker:docker:docker.io:docker" ;;
        neofetch) mapping="neofetch:neofetch:neofetch:neofetch:neofetch" ;;
        htop) mapping="htop:htop:htop:htop:htop" ;;
        tree) mapping="tree:tree:tree:tree:tree" ;;
        wget) mapping="wget:wget:wget:wget:wget" ;;
        unzip) mapping="unzip:unzip:unzip:unzip:unzip" ;;
        fzf) mapping="fzf:fzf:fzf:fzf:fzf" ;;
        jq) mapping="jq:jq:jq:jq:jq" ;;
        *) echo "$generic_name"; return ;;
    esac
    
    # Parse the mapping based on package manager
    case "$pm" in
        pacman) echo "$mapping" | cut -d':' -f2 ;;
        dnf) echo "$mapping" | cut -d':' -f3 ;;
        apt) echo "$mapping" | cut -d':' -f4 ;;
        brew) echo "$mapping" | cut -d':' -f5 ;;
        *) echo "$generic_name" ;;
    esac
}

# Main installation function
main() {
    pm=$(detect_pm)
    
    if [ "$pm" = "unknown" ]; then
        echo "Error: No supported package manager found"
        exit 1
    fi
    
    echo "Detected package manager: $pm"
    
    # Define your common packages here (space-separated)
    common_packages="editor terminal shell git curl tmux ripgrep fd bat exa nodejs python neofetch htop tree wget unzip fzf jq"
    
    # Convert generic names to package manager specific names
    actual_packages=""
    for pkg in $common_packages; do
        actual_name=$(get_package_name "$pkg" "$pm")
        actual_packages="$actual_packages $actual_name"
    done
    
    echo "Installing packages:$actual_packages"
    install_packages "$pm" $actual_packages
}

# Run if executed directly
case "$(basename "$0")" in
    install-packages.sh)
        main "$@"
        ;;
esac
