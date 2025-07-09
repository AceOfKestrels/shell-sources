#! /bin/bash

__source_all() {
    for f in "$SHELL_SOURCES_DIR/$1"/*.sh; do
        # shellcheck disable=SC1090
        source "$f"
    done
}

__source_all "shell"

if [ -d "/etc/nixos/" ]; then
    __source_all "nix"
fi