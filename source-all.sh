#!/usr/bin/env sh

__source_all() {
    # For some reason "source *.sh" does not work...
    for f in "$SHELL_SOURCES_DIR/$1"/*.sh; do
        source "$f"
    done

    # Recursively source subdirectories
    for d in "$SHELL_SOURCES_DIR/$1"/*; do
        d=$(basename "$d")
        if [ -d "$SHELL_SOURCES_DIR/$1/$d" ]; then
            __source_all "$1/$d"
        fi
    done
}

__source_all "shell"

if [ -d "/etc/nixos/" ]; then
    __source_all "nix"
fi