#! /bin/bash

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