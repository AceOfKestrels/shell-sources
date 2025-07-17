#! /bin/bash

alias cls="clear"
alias q="exit"
alias ed="editor"

alias dc="docker compose"
alias dcu="docker compose up"
alias dcb="docker compose up --build"
alias dcd="docker compose down"

dcr() {
    docker compose down "$@"
    docker compose up --build -d "$@"
}

editor() {
    if [ -z "$1" ]; then
        code .
    else
        code "$@"
    fi
}
