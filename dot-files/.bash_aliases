echo Loading bash aliases...

# ======================================================================================================================
# ==> Simple aliases.

# LS alias
alias ll='ls -lF'
alias la='ls -AF'
alias l='ls -CF'

alias lbat='bat --paging always'

alias hexdump='hexdump --canonical'

alias untarz='echo -zxvf; tar -zxvf'
alias tarup='echo -zcvf; tar -zcvf'

alias dirsize='du -ah . | sort -hr | head'

alias p='pushd .'
alias pp='dirs -v'
alias d='pushd -1'
alias s='pushd +1'

# Invoke functions.
alias j='jump'
alias jj='jumpDir'



# ======================================================================================================================
# ==> Functions.

function jump() {
    local IGNORE_DIRS=".git,host,node_modules,.idea,.m2,pkg,.vscode-server,.cache,.go,go"
    [[ -z "$1" ]] && local base="$HOME" || local base="$1";
    # Invocation in a subshell means that ctrl + c doesn't kill the main shell even thought the function runs in the
    # main shell as it is sourced.
    local selected=$(fzf --walker="file,dir,follow,hidden" --walker-root="$base" --walker-skip="$IGNORE_DIRS")
    echo "Selected: ${selected:-EMPTY}"
    [[ -n "$selected" ]] && ( [[ -d "$selected" ]] || selected=$(dirname "$selected") ) && cd "$selected"
}

function jumpDir() {
    local IGNORE_DIRS="host"
    [[ -z "$1" ]] && local base="$HOME" || local base="$1";
    # Invocation in a subshell means that ctrl + c doesn't kill the main shell even thought the function runs in the
    # main shell as it is sourced.
    local selected=$(fzf --walker='dir,follow' --walker-skip="$IGNORE_DIRS" --walker-root="$base")
    echo "Selected: ${selected:-EMPTY}"
    [[ -n "$selected" ]] && cd "$selected" || true
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
