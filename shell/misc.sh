#! /bin/bash

alias cls="clear"
alias q="exit"
alias ed="editor"

alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcb="docker compose up -d --build"
alias dcd="docker compose down"
alias dcf="docker compose logs --follow --tail 10"

dcr() {
    docker compose down "$@"
    docker compose up --build -d "$@"
}

dcl() {
    docker compose logs "$@" | less -R +G
}

editor() {
    if [ -z "$1" ]; then
        code .
    else
        code "$@"
    fi
}
