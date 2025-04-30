#! /bin/sh

niks() {
    if [ -z "$1" ]; then
        echo "usage: niks <command> [options]"
        echo "Use \"niks --help\" for a list of available commands."
        return
    fi

    local command="$1"
    shift

    case "$command" in
        create)
            __niks_create "$@"
        ;;
        --help|-h)
            __niks_help
        ;;
        *)
            echo "usage: niks <command> [options]"
            echo "Use \"niks --help\" for a list of available commands."
            return
        ;;
    esac
}

__niks_help() {
    echo "niks - Nix-Integrated Kes Scripts"
    echo
    echo "usage: niks [command] [options]"
    echo
    echo "commands:"
    echo "    generate    Generate various nix scripts, such as shells"
    echo
    echo "options:"
    echo "    --help -h   Display this help"
    echo
    echo "Use \"niks <command> --help\"" to show help for individual subcommands.
}

__niks_create() {
    if [ -z "$1" ]; then
        echo "usage: niks create <type> [options]"
        echo "Use \"niks create --help\"" for a list of available commands.
    fi

    local type="$1"
    local dir=$(dirname $(readlink -f "$0"))
    shift

    if [ -n "$1"]; then
        local path="$1"
    else
        local path="shell.nix"
    fi

    case "$type" in
        shell)
            cp "$dir/templates/shell.nix" "$path" -i
        ;;
        *)
            echo "usage: niks create <type> [options]"
            echo "Use \"niks create --help\"" for a list of available commands.
        ;;
    esac
}