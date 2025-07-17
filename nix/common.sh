#! /bin/bash

alias calc="nix-shell -p python3 --run python"

nix-channel-rollback() {
    nixos_version=$(cut --delimiter=. --fields=3 /run/current-system/nixos-version)
    channel="$(grep --fixed-strings --files-with-matches "$nixos_version" /nix/var/nix/profiles/per-user/root/channels-*-link/nixos/svn-revision | tail --lines=1 | cut --delimiter=- --fields=3)"

    sudo nix-channel --rollback "$channel"
}

upgrade() {
    defs="$(declare -f __runUpgrade rebuild nix-channel-rollback __rebuildHelp __upgradeHelp)"
    sudo bash -c "$defs; __runUpgrade $*"
}

__runUpgrade() {
    shutdown=""
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

    if ! rebuild boot "$shutdown" ; then
        nix-channel-rollback
    fi
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

    if ! sudo nixos-rebuild "$action"; then
        return
    fi

    case "$shutdown" in
        s)
            shutdown now
        ;;
        r)
            reboot
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