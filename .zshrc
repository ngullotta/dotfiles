# Enable colors and setup prompt
autoload -Uz colors && colors
setopt prompt_subst

git_current_branch() {
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  rv=$?
  if ! [ $rv = 0 ]; then
    if [ $rv = 128 ]; then
      return
    fi
    ref=$(command git rev-parse --short HEAD 2> /dev/null)
  fi
  echo -n "${ref#refs/heads/} "
}

# @ToDo -> Make this prettier!
PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{white}$(git_current_branch)%F{blue}%B%~%b%f %# '

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.cache/zsh/history"

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)  # Include hidden files

# Set-up kitty completetion, if available
if which kitty > /dev/null 2>&1; then
  kitty + complete setup zsh | source /dev/stdin
fi

# Basic history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Create a zkbd compatible hash; to add other keys to this hash
# see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"          ]] && bindkey -- "${key[Home]}"          beginning-of-line
[[ -n "${key[End]}"           ]] && bindkey -- "${key[End]}"           end-of-line
[[ -n "${key[Insert]}"        ]] && bindkey -- "${key[Insert]}"        overwrite-mode
[[ -n "${key[Backspace]}"     ]] && bindkey -- "${key[Backspace]}"     backward-delete-char
[[ -n "${key[Delete]}"        ]] && bindkey -- "${key[Delete]}"        delete-char
[[ -n "${key[Up]}"            ]] && bindkey -- "${key[Up]}"            up-line-or-beginning-search
[[ -n "${key[Down]}"          ]] && bindkey -- "${key[Down]}"          down-line-or-beginning-search
[[ -n "${key[Left]}"          ]] && bindkey -- "${key[Left]}"          backward-char
[[ -n "${key[Right]}"         ]] && bindkey -- "${key[Right]}"         forward-char
[[ -n "${key[PageUp]}"        ]] && bindkey -- "${key[PageUp]}"        beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"      ]] && bindkey -- "${key[PageDown]}"      end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}"     ]] && bindkey -- "${key[Shift-Tab]}"     reverse-menu-complete
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# -----------------------------------------------------------------------------
PATH="$PATH:$HOME/.local/bin"

setopt +o nomatch

# Initialize Plugins
plugins="$HOME/.local/share/zsh/plugins"
for plugin in "$plugins"/*; do
  if [ -e "$plugin" ]; then
    name="$(basename $plugin)"
    source "$plugin"/"$name"*.zsh
  fi
done

# Initialize functions and aliases
scripts="$HOME/.local/share/scripts/"
for script in "$scripts"/*; do
  [ -f "$script" ] && source "$script"
done

alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"