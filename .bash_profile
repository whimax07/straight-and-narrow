# Bash Profile

export _BASH_PROFILE_LOADED=true

if [ -f "$HOME/.bashrc" ] && [ "$_BASHRC_LOADED" != true ]; then
    source "$HOME/.bashrc"
fi
