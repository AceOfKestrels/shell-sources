#! /bin/bash

if [ "$1" = "--packaged" ]; then
    export SHELL_SOURCES_PACKAGED=true
fi

if [ -z "$SHELL_SOURCES_DIR" ]; then
    if [ -n "${BASH_SOURCE-}" ]; then
        SHELL_SOURCES_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
    elif [ -n "${ZSH_VERSION-}" ]; then
        # shellcheck disable=SC2296
        SHELL_SOURCES_DIR=$(realpath "$(dirname "${(%):-%N}")")
    else
        echo "shell-sources: fatal: currently only bash and zsh are supported to autodetect the script directory"
        echo "you can set SHELL_SOURCES_DIR manually"
        return 1 2>/dev/null
    fi

    export SHELL_SOURCES_DIR
fi

__source_all() {
    for f in "$SHELL_SOURCES_DIR/$1"/*.sh; do
        relative=$(realpath "$f" --relative-to="$SHELL_SOURCES_DIR")
        if echo "$SHELL_SOURCES_IGNORE" | grep "$relative" -q ; then
            continue
        fi
        # shellcheck disable=SC1090
        source "$f"
    done
}

__source_all "shell"

if [ -d "/nix" ]; then
    __source_all "nix"
fi