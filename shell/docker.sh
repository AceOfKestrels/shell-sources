#! /bin/bash

if ! where docker &>/dev/null ; then
    return
fi

if ! where sudo &>/dev/null || groups | grep -qw docker ; then

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
        if where most &>/dev/null ; then
            docker compose logs "$@" | most +G
        else
            docker compose logs "$@" | less -R +G
        fi
    }

else

    alias dc="sudo docker compose"
    alias dcu="sudo docker compose up -d"
    alias dcb="sudo docker compose up -d --build"
    alias dcd="sudo docker compose down"
    alias dcf="sudo docker compose logs --follow --tail 10"

    dcr() {
        sudo docker compose down "$@"
        sudo docker compose up --build -d "$@"
    }

    dcl() {
        if where most &>/dev/null ; then
            sudo docker compose logs "$@" | most +G
        else
            sudo docker compose logs "$@" | less -R +G
        fi
    }

fi