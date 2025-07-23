#! /bin/bash

alias cls="clear"
alias q="exit"
alias ed="editor"
alias fb="files"

editor() {
    if [ -z "$1" ]; then
        code .
    else
        code "$@"
    fi
}

files() {
    if [ -z "$FILE_BROWSER" ]; then
        echo "No browser configured. You must set FILE_BROWSER to a value."
	    return 1
    fi

    $FILE_BROWSER "${@:-.}"
}