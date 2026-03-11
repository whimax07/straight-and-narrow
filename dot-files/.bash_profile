# Bash Profile
echo Loading bash_profile...

export _BASH_PROFILE_LOADED=1
if [ -f "$HOME/.bashrc" ] && [ "$_USER_BASHRC_LOADED" != 1 ]; then
    echo Loading bashrc from profile...
    source "$HOME/.bashrc"
else
    unset _BASH_PROFILE_LOADED
    unset _USER_BASHRC_LOADED
fi
