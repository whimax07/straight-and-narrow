#!/bin/bash
echo Loading bash aliases...

# ======================================================================================================================
# ==> Simple aliases.

# LS alias
alias ll='ls -lF'
alias la='ls -AF'
alias l='ls -CF'

# \ calls the non-aliased version.
alias lbat='\bat --paging always'
alias bat='bat -S'

# To support line numbers without bad line wrapping.
alias man='MANWIDTH=$(( $COLUMNS - 5 )) man'

alias hexdump='hexdump --canonical'

alias untarz='echo -zxvf; tar -zxvf'
alias tarzup='echo -zcvf; tar -zcvf'

alias dirsize='du -ah . | sort -hr | head'

alias lp='pl'

alias p='pushd .'
alias pp='dirs -v'
alias d='pushd -1'
alias s='pushd +1'

# Invoke functions.
alias j='jump'
alias jj='jumpDir'

alias cdForward='cdThroughHistory 1'
alias cdBack='cdThroughHistory -1'
alias cd='cdHistory'
alias h='cdBack'
alias l='cdForward'
alias k='jumpToCdHistory'
alias kk='jumpToCdHistory -u'



# ======================================================================================================================
# ==> Key binding.
# This is split across here and .inputrc.

# Bind with a -x flag executes the command on the right of the ":". It also populates some useful env vars.
# Bind without the -x, expands the key sequence on the left to the key sequence on the right.

# The idea: https://superuser.com/a/1662149
# So we first save the current readline buffer and then clear it which leaves an empty command lien.
# We can now run the target command.
# To rerun the PS1 we then enter a new line (aka return) on a now empty command line.
# Once that is done we put the readline buffer back how it was, restoring the command line.

# Shared binding to restore the command line.
bind -x '"\C-x\C-x": "_loadCommandLine"'

# Binding that save the current readline buffer and then run a command(s).
bind -x '"\C-x\C-h": "_saveCommandLine; cdBack"'
bind -x '"\C-x\C-l": "_saveCommandLine; cdForward"'

# The actual user side bindings which leaves your command line unaffected and reruns(!!!) the PS1.
# The first cord is the command you want to run, \n then forces a PS1 rerun by and the second cord restores the readline
# buffer to its previous state.
bind '"\eh": "\C-x\C-h\n\C-x\C-x"'
bind '"\el": "\C-x\C-l\n\C-x\C-x"'



# ======================================================================================================================
# ==> Environment variables.

export CD_HISTORY=("$PWD")
export CD_HISTORY_POSITION=0
export CD_HISTORY_UNIQUE=("$PWD")
export CD_HISTORY_SIZE=${CD_HISTORY_SIZE:-250}



# ======================================================================================================================
# ==> Functions.

function pl() {
    if [[ "$1" == "-p" || "$1" == "--pretty" ]] && hash \bat; then
        podman logs "$1" | bat --pager="less -R -f -n" -l log
    else
        streamToFile "less" podman logs -f "$1"
    fi
}

function jump() {
    local IGNORE_DIRS=".git,host,node_modules,.idea,.m2,pkg,.vscode-server,.cache,.go,go"
    local base; [[ -z "$1" ]] && base="$HOME" || base="$1";
    # Invocation in a subshell means that ctrl + c doesn't kill the main shell even thought the function runs in the
    # main shell as it is sourced.
    local selected; selected=$(fzf --walker="file,dir,follow,hidden" --walker-root="$base" --walker-skip="$IGNORE_DIRS")
    echo "Selected: ${selected:-EMPTY}"
    [[ -n "$selected" ]] && { [[ -d "$selected" ]] || selected=$(dirname "$selected"); } && cdHistory "$selected" || return 0
}

function jumpDir() {
    local IGNORE_DIRS="host"
    local base; [[ -z "$1" ]] && base="$HOME" || base="$1";
    # Invocation in a subshell means that ctrl + c doesn't kill the main shell even thought the function runs in the
    # main shell as it is sourced.
    local selected; selected=$(fzf --walker='dir,follow' --walker-skip="$IGNORE_DIRS" --walker-root="$base")
    echo "Selected: ${selected:-EMPTY}"
    [[ -n "$selected" ]] && cdHistory "$selected" || return 0
}

function jumpToCdHistory() {
    local selected
    if [[ "$1" == "-u" ]]; then
        selected=$(printf "%s\n" "${CD_HISTORY_UNIQUE[@]}" | fzf --tac --no-sort)
    else
        selected=$(printf "%s\n" "${CD_HISTORY[@]}" | fzf --tac --no-sort)
    fi
    echo "Selected: ${selected:-EMPTY}"
    [[ -n "$selected" ]] && cdHistory "$selected" || return 0
}

function cdHistory() {
    local last_dir="$PWD"
    # \ calls the non-aliased version.
    \cd "$@" || return $?

    if [[ "$last_dir" == "$PWD" ]]; then return 0; fi

    # Check if we need to clear some of the buffer, everything after the current position. This happens when you are
    # NOT at the end of the history but cdHistory is called.
    if ! _boundsCheckCdHistory +1; then CD_HISTORY=("${CD_HISTORY[@]:0:CD_HISTORY_POSITION + 1}"); fi

    CD_HISTORY+=("$PWD")
    CD_HISTORY_POSITION=$(( CD_HISTORY_POSITION + 1 ))

    # Check to see if the history buffer size needs reducing.
    local array_size="${#CD_HISTORY[@]}"
    if (( array_size > CD_HISTORY_SIZE )); then
        local new_start=$(( array_size - CD_HISTORY_SIZE ))
        # Get the range with indexes [new_start,array_size).
        CD_HISTORY=("${CD_HISTORY[@]:new_start}")
        CD_HISTORY_POSITION=$(( CD_HISTORY_POSITION - new_start ))
    fi

    # Manage the unique list of visited directories.
    local copy_array=()
    for path in "${CD_HISTORY_UNIQUE[@]}"; do
        [[ "$PWD" == "$path" ]] || copy_array+=("$path")
    done
    copy_array+=("$PWD")

    local start_index=$(( ${#copy_array[@]} - CD_HISTORY_SIZE ))
    if (( start_index < 0 )); then start_index=0; fi
    CD_HISTORY_UNIQUE=("${copy_array[@]:start_index}")
}

function cdThroughHistory() {
    local change="$1"
    _pruneDeadHistory "$change"
    if _boundsCheckCdHistory "$change"; then echo "At the end of CD History."; return 0; fi

    local next_position=$(( CD_HISTORY_POSITION + change ))
    local next_dir="${CD_HISTORY[next_position]}"

    # \ calls the non-aliased version.
    \cd "$next_dir" || return $?
    CD_HISTORY_POSITION="$next_position"
}

function _pruneDeadHistory() {
    local change="$1"
    if _boundsCheckCdHistory "$change"; then return 0; fi
    if [[ -d "${CD_HISTORY[CD_HISTORY_POSITION + change]}" ]]; then return 0; fi

    local cleaned_array=()
    local position_slide=0
    for (( i=0; i < ${#CD_HISTORY[@]}; i++ )); do
        local dir_to_test="${CD_HISTORY[i]}"

        if [[ -d "$dir_to_test" ]]; then cleaned_array+=("$dir_to_test")
        elif (( i < CD_HISTORY_POSITION )); then (( position_slide++ ))
        fi
    done

    CD_HISTORY=("${cleaned_array[@]}")
    CD_HISTORY_POSITION=$(( CD_HISTORY_POSITION - position_slide ))
}

function _boundsCheckCdHistory() {
    (( CD_HISTORY_POSITION + $1 < 0 )) || (( CD_HISTORY_POSITION + $1 >= "${#CD_HISTORY[@]}" ));
}

STREAM_TO_FILE_PID=
STREAM_TO_FILE_FILE=
function cleanUpStreamToFile() {
    echo "Killing PID: $STREAM_TO_FILE_PID, File: $STREAM_TO_FILE_FILE"
    kill -TERM "$STREAM_TO_FILE_PID" 2>/dev/null;
    rm -f "$STREAM_TO_FILE_FILE";
}

function streamToFile() {
    local view_command
    view_command="$1"
    shift
    STREAM_TO_FILE_FILE=$(mktemp -t "streaming_to_file.$BASHPID.XXXXXX") || return 1

    setsid "$@" >>"$STREAM_TO_FILE_FILE" 2>&1 &
    STREAM_TO_FILE_PID=$!
    trap cleanUpStreamToFile EXIT INT TERM RETURN

    echo "PID: $STREAM_TO_FILE_PID"
    sleep 0.5
    eval $view_command "$STREAM_TO_FILE_FILE"
}



# ======================================================================================================================
# ==> Utility functions.

function _saveCommandLine() {
    export READLINE_LINE_OLD="$READLINE_LINE"
    export READLINE_POINT_OLD="$READLINE_POINT"
    export READLINE_LINE=
    export READLINE_POINT=0
}

function _loadCommandLine() {
    export READLINE_LINE="$READLINE_LINE_OLD"
    export READLINE_POINT="$READLINE_POINT_OLD"
}



# ======================================================================================================================
# ==> Inherited with my PS1 implementation.

# Add an "alert" alias for long-running commands.  Use like so:
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
