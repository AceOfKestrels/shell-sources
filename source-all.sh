#!/usr/bin/env sh

__source_all() {
    # For some reason "source *.sh" does not work...
    for f in "$SHELL_SOURCES_DIR/$1"/*.sh; do
        source "$f"
    done
}

__source_all "shell"

if [ -d "/etc/nixos/" ]; then
    __source_all "nix"
fi