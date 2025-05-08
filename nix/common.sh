#! /bin/sh

upgrade() {
    shutdown="-s"
    if [ -n "$1" ]; then
        case "$1" in
            --shutdown|-s|--reboot|-r)
                shutdown="$1"
            ;;
            --help|-h)
                __upgradeHelp
                return
            ;;
            *)
                echo "usage: upgrade [options]"
                return
            ;;
        esac
    fi

    if ! sudo nix-channel --update; then
        echo "Failed to update channel..."
        return
    fi

    rebuild boot "$shutdown"
}

rebuild() {
    action="switch"
    if [ -n "$1" ]; then
        case "$1" in
            switch|boot)
                action="$1"
                shift
            ;;
            --shutdown|-s)
                shutdown="1"
            ;;
            --reboot|-r)
                shutdown="2"
            ;;
            --help|-h)
                __rebuildHelp
                return
            ;;
            *)
                echo "usage: rebuild [action] [options]"
                return
            ;;
        esac
    fi

    shutdown=""
    if [ -n "$1" ]; then
        case "$1" in
            --help|-h)
                __rebuildHelp
                return
            ;;
            --shutdown|-s)
                shutdown="s"
            ;;
            --reboot|-r)
                shutdown="r"
            ;;
            *)
                echo "usage: rebuild [action] [options]"
                return
            ;;
        esac
    fi

    sudo nixos-rebuild "$action"

    case "$shutdown" in
        s)
            shutdown now
        ;;
        r)
            reboot now
        ;;
    esac
}

__rebuildHelp() {
    echo "usage: rebuild [action] [options]"
    echo
    echo "actions:"
    echo "    switch         Run nixos-rebuild switch"
    echo "    boot           Run nixos-rebuild boot"
    echo
    echo "options:"
    echo "    --shutdown -s  Shutdown afterwards"
    echo "    --reboot -b    Reboot afterwards"
    echo "    --help -h      Show this help"
}

__upgradeHelp() {
    echo "usage: upgrade [options]"
    echo
    echo "options:"
    echo "    --shutdown -s  Shutdown afterwards"
    echo "    --reboot -b    Reboot afterwards"
    echo "    --help -h      Show this help"
}