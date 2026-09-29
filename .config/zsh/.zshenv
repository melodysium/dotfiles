#!/bin/zsh
# 1) .zshenv: always sourced. include $PATH, $EDITOR, etc.
# reminder: help_zsh_dotfiles.md

# enable to debug slow startup times
#set -x

# 2025-10-28: do PATH things later for login shells to get around system-sourced files messing with my prompt settings
# https://www.zsh.org/mla/users/2003/msg00600.html
#if [[ $SHLVL == 1 && ! -o LOGIN ]]; then # 2025-11-11 remove SHLVL == 1 check bc intellij loads in SHLVL 2
if [[ ! -o LOGIN ]]; then
    source "${ZDOTDIR}/.zpath"
fi


#set +x
