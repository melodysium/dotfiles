

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

. "$HOME/.cargo/env"
. "$HOME/.local/bin/env"

eval "$(/opt/homebrew/bin/brew shellenv)"


# nvm/npm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export BASHRC_LOCAL=".bashrc.local"
if [[ -f "$BASHRC_LOCAL" ]]; then
  source "$BASHRC_LOCAL"
fi