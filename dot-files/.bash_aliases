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

alias cd='cdHistory'
alias h='cdBack'
alias l='cdForward'


# ======================================================================================================================
# ==> Functions.

function jump() {
    local IGNORE_DIRS=".git,host,node_modules,.idea,.m2,pkg,.vscode-server,.cache,.go,go"
    [[ -z "$1" ]] && local base="$HOME" || local base="$1";
    # Invocation in a subshell means that ctrl + c doesn't kill the main shell even thought the function runs in the
    # main shell as it is sourced.
    local selected=$(fzf --walker="file,dir,follow,hidden" --walker-root="$base" --walker-skip="$IGNORE_DIRS")
    echo "Selected: ${selected:-EMPTY}"
    [[ -n "$selected" ]] && { [[ -d "$selected" ]] || selected=$(dirname "$selected"); } && cd "$selected" || true
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

export CD_HISTORY=("$PWD")
export CD_HISTORY_POSITION=0
export CD_HISTORY_UNIQUE=("$PWD")
export CD_HISTORY_SIZE=${CD_HISTORY_SIZE:-100}
function cdHistory() {
    # Get the current directory and then go to the next directory.
    local last_dir="$PWD"
    # \ calls the non-aliased version.
    \cd "$@" || return $?

    if [[ "$last_dir" == "$PWD" ]]; then return 0; fi

    # Clear overridden history, then append the last dir to the to the history.
    local array_size="${#CD_HISTORY[@]}"
    if (( CD_HISTORY_POSITION + 1 < array_size )); then
        # We need to clear some of the buffer, 0 to the current position.
        CD_HISTORY=("${CD_HISTORY[@]:0:CD_HISTORY_POSITION + 1}")
    fi

    CD_HISTORY+=("$PWD")
    CD_HISTORY_POSITION=$(( CD_HISTORY_POSITION + 1 ))

    # Check to see if the history buffer size needs reducing.
    local array_size="${#CD_HISTORY[@]}"
    if (( array_size > CD_HISTORY_SIZE )); then
        local new_start=$(( array_size - CD_HISTORY_SIZE ))
        # Get the range with indexes [new_start,array_size).
        CD_HISTORY=("${CD_HISTORY[@]:new_start}")
    fi
}

function cdBack() {
    # Exit early with a successful error code if we are at the start of history.
    if (( CD_HISTORY_POSITION <= -1 )); then
        echo "At the start of cd history."
        return 0
    fi

    local next_position=$(( CD_HISTORY_POSITION - 1 ))
    local next_dir="${CD_HISTORY[next_position]}"

    # \ calls the non-aliased version.
    \cd "$next_dir" || return $?
    CD_HISTORY_POSITION="$next_position"
}

function cdForward() {
    if (( CD_HISTORY_POSITION + 1 >= "${#CD_HISTORY[@]}" )); then
        echo "At the end of cd history."
        return 0
    fi

    local next_position=$(( CD_HISTORY_POSITION + 1 ))
    local next_dir="${CD_HISTORY[next_position]}"

    # \ calls the non-aliased version.
    \cd "$next_dir" || return $?
    CD_HISTORY_POSITION="$next_position"
}

function cdStatus() {
    local array_size="${#CD_HISTORY[@]}"
    printf "History buffer status. [Index=%s, Size=%s, Capacity=%s]\n" \
        "$CD_HISTORY_POSITION" "$array_size" "$CD_HISTORY_SIZE"

    printf "Previous: "
    if (( CD_HISTORY_POSITION > 1 )); then
        printf "%s" "${CD_HISTORY[CD_HISTORY_POSITION - 1]}"
    fi
    printf "\n"

    printf "Next: "
    if (( CD_HISTORY_POSITION + 1 < array_size )); then
        printf "%s" "${CD_HISTORY[CD_HISTORY_POSITION + 1]}"
    fi
    printf "\n"
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
