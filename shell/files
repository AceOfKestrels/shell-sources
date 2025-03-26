#!/usr/bin/env sh

alias ..="cd .."

alias la="ls -A"
alias ll="ls -l"
alias lla="ls -l -A"

lgrep() {
    if [ -z "$1" ]
    then
        echo "error: search requires a value"
        echo
        echo "lgrep: ls | grep"
        echo "usage: lgrep [search]"
        echo "related commands: lag llg llag"
    else
        ls | grep "$@"
    fi
}

lag() {
    if [ -z "$1" ]
    then
        echo "error: search requires a value"
        echo
        echo "lag: la | grep"
        echo "usage: lag [search]"
        echo "related commands: lgrep llg llag"
    else
        la | grep "$@"
    fi
}

llg() {
    if [ -z "$1" ]
    then
        echo "error: search requires a value"
        echo
        echo "llg: ll | grep"
        echo "usage: llg [search]"
        echo "related commands: lgrep lag llag"
    else
        ll | grep "$@"
    fi
}

llag() {
    if [ -z "$1" ]
    then
        echo "error: search requires a value"
        echo
        echo "llag: lla | grep"
        echo "usage: llag [search]"
        echo "related commands: lgrep lag llg"
    else
        lla | grep "$@"
    fi
}