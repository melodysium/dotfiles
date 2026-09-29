# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

# echo "hello from .profile!"
. "$HOME/.cargo/env"
. "$HOME/.local/bin/env"

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export PROFILE_LOCAL=".profile.local"
if [[ -f "$PROFILE_LOCAL" ]]; then
  source "$PROFILE_LOCAL"
fi
