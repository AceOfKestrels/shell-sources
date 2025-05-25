#!/usr/bin/env sh

alias cls="clear"
alias q="exit"
alias ed="editor"

editor() {
    if [ -z "$1" ]; then
        code .
    else
        code "$@"
    fi
}

search() {
    if [ -z "$SEARCH_BROWSER" ]; then
        echo "No browser configured. You must set SEARCH_BROWSER to a value."
	    return
    fi

    if [ -z "$1" ]; then
        echo "usage: search <term>"
        return
    fi

    $SEARCH_BROWSER $SEARCH_BROWSER_ARGS "$@"
}