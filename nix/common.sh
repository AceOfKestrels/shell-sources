#! /bin/bash

alias calc="nix-shell -p python3 --run python"

nix-channel-rollback() {
    nixos_version=$(cut --delimiter=. --fields=3 /run/current-system/nixos-version)
    channel="$(grep --fixed-strings --files-with-matches "$nixos_version" /nix/var/nix/profiles/per-user/root/channels-*-link/nixos/svn-revision | tail --lines=1 | cut --delimiter=- --fields=3)"

    sudo nix-channel --rollback "$channel"
}

alias __keep-sudo-alive="__start_sudo_keeper; trap __stop_sudo_keeper EXIT INT TERM"

upgrade() {
    if [ -n "$1" ]; then
        case "$1" in
            --help|-h)
                __rebuildHelp
                return 1
            ;;
        esac
    fi

    __keep-sudo-alive

    if ! sudo nix-channel --update; then
        echo "Failed to update channel..."
        return 1
    fi

    if ! rebuild "$@" ; then
        nix-channel-rollback
        return 1
    fi
}

rebuild() {
    action="switch"
    shutdown=""
    if [ -n "$1" ]; then
        case "$1" in
            switch|boot)
                action="$1"
                shift
            ;;
            --shutdown|-s)
                shutdown="s"
                shift
            ;;
            --reboot|-r)
                shutdown="r"
                shift
            ;;
            --help|-h)
                __rebuildHelp
                return 1
            ;;
        esac
    fi

    if [ -n "$1" ]; then
        case "$1" in
            --help|-h)
                __rebuildHelp
                return 1
            ;;
            --shutdown|-s)
                shutdown="s"
                shift
            ;;
            --reboot|-r)
                shutdown="r"
                shift
            ;;
        esac
    fi

    if where nh &> /dev/null; then
        if ! nh os "$action" -f '<nixpkgs/nixos>' "$@"; then
            return 1
        fi
    else
        if ! sudo nixos-rebuild "$action" "$@"; then
            return 1
        fi
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
    echo "uses nh if available, otherwise defaults to nixos-rebuild"
    echo
    echo "actions:"
    echo "    switch         Run nixos-rebuild switch"
    echo "    boot           Run nixos-rebuild boot"
    echo
    echo "options:"
    echo "    --shutdown -s  Shutdown afterwards"
    echo "    --reboot -b    Reboot afterwards"
    echo "    --help -h      Show this help"
    echo
    echo "additional arguments are passed to the rebuild command"
}

__start_sudo_keeper() {
    sudo -v

    set +m
    (
        while true; do
            sleep 60
            sudo -v
        done
    ) &

    SUDO_REFRESH_PID=$!
}

__stop_sudo_keeper() {
    set +m
    kill "$SUDO_REFRESH_PID" 2>/dev/null
}