
function _pl_completion() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local flags=("-l" "--less")
    if [[ "$COMP_CWORD" == 1 ]]; then
        local options=("${flags[@]}")
        options+=$(podman ps -a --format '{{.Names}}' | grep -vE '^[0-9a-fA-F]+-infra$')
        COMPREPLY=( $(compgen -W "$options" -- "$current_word") )
    elif [[ "$COMP_CWORD" == 2 ]] && [[ "$current_word" == "-l" || "$current_word" == "--less" ]]; then
        local options=$(podman ps -a --format '{{.Names}}' | grep -vE '^[0-9a-fA-F]+-infra$')
        COMPREPLY=( $(compgen -W "$options" -- "$current_word") )
    fi
}

complete -F _pl_completion pl
complete -F _pl_completion lp

