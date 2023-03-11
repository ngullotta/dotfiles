#!/bin/zsh
# shellcheck disable=SC2169 # < We know this isn't dash :^)

# Enable colors and setup prompt
autoload -Uz colors && colors
setopt prompt_subst

git_current_branch() {
  ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  [ -n "$ref" ] && echo -n "${ref#refs/heads/} "
}

# @ToDo -> Make this prettier!
# shellcheck disable=SC2016

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.cache/zsh/history"

[ -f "$HISTFILE" ] || mkdir -p "$(dirname $HISTFILE)"
[ -f "$HISTFILE" ] || touch "$HISTFILE"

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -i
_comp_options+=(globdots)  # Include hidden files

# Set-up kitty completetion, if available
if which kitty > /dev/null 2>&1; then
  # shellcheck disable=SC1090
  source <(kitty + complete setup zsh)
fi

# Basic history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Create a zkbd compatible hash; to add other keys to this hash
# see: man 5 terminfo
typeset -g -A key

# shellcheck disable=SC2154
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
[ -n "${key[Home]}"          ] && bindkey -- "${key[Home]}"          beginning-of-line
[ -n "${key[End]}"           ] && bindkey -- "${key[End]}"           end-of-line
[ -n "${key[Insert]}"        ] && bindkey -- "${key[Insert]}"        overwrite-mode
[ -n "${key[Backspace]}"     ] && bindkey -- "${key[Backspace]}"     backward-delete-char
[ -n "${key[Delete]}"        ] && bindkey -- "${key[Delete]}"        delete-char
[ -n "${key[Up]}"            ] && bindkey -- "${key[Up]}"            up-line-or-beginning-search
[ -n "${key[Down]}"          ] && bindkey -- "${key[Down]}"          down-line-or-beginning-search
[ -n "${key[Left]}"          ] && bindkey -- "${key[Left]}"          backward-char
[ -n "${key[Right]}"         ] && bindkey -- "${key[Right]}"         forward-char
[ -n "${key[PageUp]}"        ] && bindkey -- "${key[PageUp]}"        beginning-of-buffer-or-history
[ -n "${key[PageDown]}"      ] && bindkey -- "${key[PageDown]}"      end-of-buffer-or-history
[ -n "${key[Shift-Tab]}"     ] && bindkey -- "${key[Shift-Tab]}"     reverse-menu-complete
[ -n "${key[Control-Left]}"  ] && bindkey -- "${key[Control-Left]}"  backward-word
[ -n "${key[Control-Right]}" ] && bindkey -- "${key[Control-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if [ -n "${+terminfo[smkx]}" ] && [ -n "${+terminfo[rmkx]}" ]; then
  autoload -Uz add-zle-hook-widget
  zle_application_mode_start() { echoti smkx; }
  zle_application_mode_stop() { echoti rmkx; }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# -----------------------------------------------------------------------------
PATH="$PATH:$HOME/.local/bin:$HOME/.local/bin/newsboat"

setopt +o nomatch

# Initialize Plugins
plugins="$HOME/.local/share/zsh/plugins"
for plugin in "$plugins"/*; do
  if [ -e "$plugin" ]; then
    name="$(basename "$plugin")"
    # shellcheck source=/dev/null
    if [ "$(echo $plugin/$name*.zsh)" != "$plugin/$name*.zsh" ]; then
      source "$plugin"/"$name"*.zsh
    else
      source "$plugin"/*.zsh
    fi
  fi
done

# Initialize functions and aliases
scripts="$HOME/.local/share/scripts/"
for script in "$scripts"/*; do
  # shellcheck source=/dev/null
  [ -f "$script" ] && source "$script"
done

alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Allows auto-complete even through alias
setopt complete_aliases

# System clipboard integration - copy the kill (cut) buffer to the system
# clipboard on each change (e.g. on Ctrl+Insert, Ctrl+W, ...).
#
# NOTE: It must be loaded after the main keymap is selected, i.e. after
# 50-key-bindings.zsh.

# The clipboard to synchronize the cut buffer with.
# Allowed values: "primary" (selection), or "clipboard" (regular clipboard).
# TIP: If you want to override this, do it in your $ZDOTDIR/.zshenv.
: ${ZSH_CUTBUFFER_CLIPBOARD:=clipboard}

# An array of $TERM values that identify terminals with OSC 52 support (access
# to system clipboard). This is just a shortcut to skip dynamic detection using
# `tty-copy --test` for known terminals.
if (( ! ${+osc52_supported_terms} )); then
	osc52_supported_terms=('alacritty' 'foot' 'xterm-kitty')
fi

function () {
	emulate -L zsh -o no_aliases

	# NOTE: We have to redirect stdout/stderr to /dev/null for wl-copy and
	#  xclip, otherwise terminal hangs when exited!
	if [[ -n "${WAYLAND_DISPLAY-}" ]] && (( ${+commands[wl-copy]} )); then
		function .zshrc::clip-copy() {
			local opts=
			[[ "$ZSH_CUTBUFFER_CLIPBOARD" = 'primary' ]] && opts='--primary'
			wl-copy $opts -- "$@" >/dev/null 2>&1
		}
	elif [[ -n "${DISPLAY-}" ]] && (( ${+commands[xclip]} )); then
		function .zshrc::clip-copy() {
			printf '%s' "$*" | xclip -in -selection ${ZSH_CUTBUFFER_CLIPBOARD:-primary} >/dev/null 2>&1
		}
	elif (( ${+commands[tty-copy]} )) \
		&& { (( ${osc52_supported_terms[(Ie)$TERM]} )) || tty-copy --test; };
	then
		function .zshrc::clip-copy() {
			local opts=
			[[ "$ZSH_CUTBUFFER_CLIPBOARD" = 'primary' ]] && opts='--primary'
			tty-copy $opts -- "$@"
		}
	else
		return 0
	fi

	autoload -Uz add-zle-hook-widget

	declare -gH _ZSHRC_CUTBUFFER_LAST=''

	function .zshrc::sync-cutbuffer-with-clipboard() {
		if [[ "$CUTBUFFER" != "$_ZSHRC_CUTBUFFER_LAST" ]]; then
			.zshrc::clip-copy "$CUTBUFFER"
			_ZSHRC_CUTBUFFER_LAST=$CUTBUFFER
		fi
	}
	add-zle-hook-widget line-pre-redraw .zshrc::sync-cutbuffer-with-clipboard
}

# vim: set ts=4 sw=4:


x-copy-region-as-kill () {
  zle copy-region-as-kill
  print -rn $CUTBUFFER | xsel -i -b
}
zle -N x-copy-region-as-kill
x-kill-region () {
  zle kill-region
  print -rn $CUTBUFFER | xsel -i -b
}
zle -N x-kill-region
x-yank () {
  CUTBUFFER=$(xsel -o -b </dev/null)
  zle yank
}
zle -N x-yank
bindkey -e '\ew' x-copy-region-as-kill
bindkey -e '^W' x-kill-region
bindkey -e '^Y' x-yank
