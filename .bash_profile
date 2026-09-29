# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.


# echo "hello from .bash_profile!"
. "$HOME/.cargo/env"
. "$HOME/.local/bin/env"

export BASH_PROFILE_LOCAL=".bash_profile.local"
if [[ -f "$BASH_PROFILE_LOCAL" ]]; then
  source "$BASH_PROFILE_LOCAL"
fi
