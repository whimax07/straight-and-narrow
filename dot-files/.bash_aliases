echo Loading bash aliases...

# ======================================================================================================================
# ==> Simple aliases.

# LS alias
alias ll='ls -lF'
alias la='ls -AF'
alias l='ls -CF'

alias cat='bat'
alias lbat='bat --paging always'

alias hexdump='hexdump --canonical'

alias untarz='echo -zxvf; tar -zxvf'
alias tarup='echo -zcvf; tar -zcvf'

alias dirsize='du -ah . | sort -hr | head'

alias p='pushd .'
alias pp='dirs -v'
alias d='pushd -1'
alias s='pushd +1'



# ======================================================================================================================
# ==> Function based aliases.

alias j='jump'
function jump() {
    # This function will be sourced when the aliases are applied. That means it is available to call AND the function
    # is NOT ran in a sub-shell meaning the cd actually changes your terminal's directory. The actual implementation
    # using fzf is ran in a subshell so if I ctrl + C a search it doesn't kill the session.
    local selected="$("$HOME/straight-and-narrow/support/jump" "$@")"
    echo "Selected: ${selected:-EMPTY}"
    if [[ -n "$selected" ]]; then cd "$selected"; fi
}



# ======================================================================================================================
# ==> Inherited with my PS1 implementation.

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    # I have replaced this for .set_ls_theme because I had forgotten this was a thing.
    # test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
