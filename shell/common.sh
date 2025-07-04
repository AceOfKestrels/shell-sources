#!/usr/bin/env sh

# Only in bash; In ZSH handled through plugins
if [ -n "$BASH_VERSION" ]; then
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous on"
fi

__currentusername="$(whoami)"
__desktoppath="$HOME/Desktop"

home() {
    cd ~ || return

    echo "Welcome home, $__currentusername!"
}

desktop() {
    cd "$__desktoppath" || return
}


reload() {
    echo "Reloading..."
    if [ -z "$1" ]
    then
        exec $SHELL
    fi

    if [ "$1" = "-u" ] || [ "$1" = "--update" ]
    then
        cd "$SHELL_SOURCES_DIR" || return
        git pull 
        cd - >/dev/null 2>&1 || return
        exec $SHELL
    fi

    echo "reload: \"reload .bashrc\""
    echo "usage: \"reload <options>\""
    echo ""
    echo "options:"
    echo "  -u --update  Pull new changes from remote before reloading"
}
