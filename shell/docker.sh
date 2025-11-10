#! /bin/bash

alias dcu="dc up -d"
alias dcub="dc up -d --build"
alias dcb="dc build"
alias dcd="dc down"
alias dcf="dc logs --follow --tail 10"

dc() {
    # user has docker access OR sudo is not installed anyways
    if docker info >/dev/null 2>&1 || ! command -v sudo >/dev/null 2>&1; then
        docker compose "$@"
    else # user has no docker access, and sudo is installed
        sudo docker compose "$@"
    fi
}

dcr() {
    dc down "$@"
    dc up --build -d "$@"
}

dcl() {
    if where most &>/dev/null ; then
        dc logs "$@" | most +G
    else
        dc logs "$@" | less -R +G
    fi
}
