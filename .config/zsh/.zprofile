#!/bin/zsh
# 2) .zprofile: for login shells. (first user shell)
# use sparingly

# enable to debug slow startup times
#set -x
#echo "start .zprofile"

# 2026-09-24: always load .zpath here in login shells. companion to non-login loader in .zshenv.
source "${ZDOTDIR}/.zpath"

##set +x
#echo "end .zprofile"

