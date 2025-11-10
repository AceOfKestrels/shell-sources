#! /bin/bash

if command -v bind >/dev/null 2>&1; then
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous on"
fi

reload() {
    if [ -z "$1" ]; then
        echo "Reloading shell..."
        exec $SHELL
    fi

    if [ "$1" = "-u" ] || [ "$1" = "--update" ]; then
        cd "$SHELL_SOURCES_DIR" >/dev/null || return 1
        git pull 
        cd - >/dev/null 2>&1 || return 1
        echo
        echo "Reloading shell..."
        exec $SHELL
    fi

    echo -e "${F_FG_BLUE}usage${F_RESET}: reload [options]"

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo
        echo "reload shell profile"
        echo
        echo -e "${F_FG_BLUE}options:${F_RESET}"
        echo -e "    ${F_FG_YELLOW}-u --update  ${F_RESET}Pull new changes from remote before reloading"
    fi

    return 1
}
