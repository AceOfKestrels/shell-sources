#! /bin/bash

alias cls="clear"
alias q="exit"

alias hibernate="systemctl hibernate"
alias suspend="systemctl suspend"

ed() {
    cmd="$CODE_PROGRAM"

    if [ -z "$cmd" ]; then
        cmd="code"
    fi

    if [ -z "$@" ]; then
        $cmd .
        return 0
    fi

    $cmd "$@"
}

ex() {
    cmd="$FILE_BROWSER"

    if [ -z "$cmd" ]; then
        echo "FILE_BROWSER variable is not set"
        return 1
    fi

    $cmd "$@"
}