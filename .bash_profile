# Bash Profile
echo Loading bash_profile...


export _BASH_PROFILE_LOADED=true
if [ -f "$HOME/.bashrc" ] && [ "$_BASHRC_LOADED" != true ]; then
    echo Loading bashrc from profile...
    source "$HOME/.bashrc"
else
    unset _BASH_PROFILE_LOADED
    unset _BASHRC_LOADED
fi
