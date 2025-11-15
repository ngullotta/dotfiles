export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -i
_comp_options+=(globdots)  # Include hidden files

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="${XDG_CACHE_HOME}/${0}history"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME}/zinit"
if [ -d "$ZINIT_HOME" ]; then
    source "${ZINIT_HOME}/zinit.zsh"
else
    printf "Could not find zinit script along $ZINIT_HOME\n" > /dev/stderr
fi

PLUGINS=(
    "ajeetdsouza/zoxide"
    "zsh-users/zsh-syntax-highlighting"
    "romkatv/powerlevel10k"
    "zsh-users/zsh-autosuggestions"
    "nickKaramoff/ohmyzsh-key-bindings"
    "jirutka/zsh-shift-select"
)

if command -v zinit > /dev/null 2>&1; then
    for plugin in "$PLUGINS[@]"; do
        zinit ice depth=1; zinit light "${plugin}"
    done
fi

# Default prompt if no others installed
PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion history)

command -v zoxide > /dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v kitty > /dev/null 2>&1 && source <(kitty + complete setup zsh)

# Copy for all major OS I use
function _copy() {
    local text="$1" # Use a local variable for clarity and safety
    if command -v xclip &>/dev/null; then
        # Explicitly close stdin for xclip after sending the text
        print -rn -- "$text" | xclip -selection primary -i </dev/null && \
        print -rn -- "$text" | xclip -selection clipboard -i </dev/null
    elif command -v pbcopy &>/dev/null; then
        print -rn -- "$text" | pbcopy
    fi
}

# Copy the selected region to the clipboard.
function shift-select::copy-region() {
  local start=${MARK} end=${CURSOR}
  if (( $start > $end )); then
    local tmp=$start
    start=$end
    end=$tmp
  fi

  # Extract the selected text
  local selected_text="${BUFFER[${start},${end}]}"

  # Copy the selected text to the clipboard using pbcopy
  _copy "${selected_text}"
}
zle -N shift-select::copy-region

bindkey -M shift-select 'e' shift-select::copy-region

# Bind aliases
[[ -r "$HOME/.aliasrc" ]] && source "$HOME/.aliasrc"
