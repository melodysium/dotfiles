#!/bin/zsh
# 4) .zlogin: login, after .zshrc. external commands that don't modify shell
# reminder: help_zsh_dotfiles.md

# navi setup
# 2025-10-28 replace default widget with my own that just changes the keybind
#eval "$(navi widget zsh)"
source "${ZDOTDIR}/.navi.sh"

#   Keybinds
#   -------------------------------------------
#bindkey "${key[Up]}" fzf-history-widget
bindkey "^R" fzf-history-widget
