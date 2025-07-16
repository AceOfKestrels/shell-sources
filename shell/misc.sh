#! /bin/bash

alias cls="clear"
alias q="exit"
alias ed="editor"
alias dc="docker compose"

editor() {
    if [ -z "$1" ]; then
        code .
    else
        code "$@"
    fi
}
