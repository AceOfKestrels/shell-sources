#! /bin/bash

alias dcu="dc up -d"
alias dcub="dc up -d --build"
alias dcb="dc build"
alias dcd="dc down"
alias dcf="dc logs --follow --tail 10"

dc() {
    # user has docker access
    if docker info >/dev/null 2>&1; then
        docker compose "$@"
    # user has sudo access to docker
    elif sudo docker info >/dev/null; then
        sudo docker compose "$@"
    else
        echo "fatal: unable to access docker"
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
