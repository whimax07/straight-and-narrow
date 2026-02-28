
function _pl_completion() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local containers=$(podman ps -a --format '{{.Names}}' | grep -vE '^[0-9a-fA-F]+-infra$')
    local flags="-p"$'\n'"--pretty"$'\n'
    if [[ "$COMP_CWORD" == 1 ]]; then
        local options="$containers"$'\n'"$flags"
        COMPREPLY=( $(compgen -W "$options" -- "$current_word") )
    elif [[ "$COMP_CWORD" == 2 ]] && [[ "${COMP_WORDS[1]}" == "-l" || "${COMP_WORDS[1]}" == "--less" ]]; then
        COMPREPLY=( $(compgen -W "$containers" -- "$current_word") )
    fi
}

complete -F _pl_completion pl
complete -F _pl_completion lp

