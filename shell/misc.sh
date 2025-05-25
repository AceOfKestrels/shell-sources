#!/usr/bin/env sh

alias cls="clear"
alias ed="editor"

editor() {
    if [ -z "$1" ]; then
        code .
    else
        code "$@"
    fi
}