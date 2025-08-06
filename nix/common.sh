#! /bin/bash

alias calc="nix-shell -p python3 --run python"

nix-channel-rollback() {
    nixos_version=$(cut --delimiter=. --fields=3 /run/current-system/nixos-version)
    channel="$(grep --fixed-strings --files-with-matches "$nixos_version" /nix/var/nix/profiles/per-user/root/channels-*-link/nixos/svn-revision | tail --lines=1 | cut --delimiter=- --fields=3)"

    sudo nix-channel --rollback "$channel"
}

# helper to keep the sudo from timing out while upgrading
# we need sudo again to revert the channel if upgrade fails
alias __keep-sudo-alive="__start_sudo_keeper; trap __stop_sudo_keeper EXIT INT TERM"

upgrade() {
    action="switch"
    ushutdown=""
    commitFlakeLock=0

    if [ -n "$1" ]; then
        case "$1" in
            switch|boot)
                action="$1"
                shift
            ;;
        esac
    fi

    if [ "$COMMIT_FLAKE_LOCK" = 1 ]; then
        commitFlakeLock=1
    fi

    if [ -n "$1" ]; then
        for arg in "$@"; do
            case "$arg" in
                --help|-h)
                    __upgradeHelp
                    return 0
                ;;
                --shutdown|-s)
                    ushutdown="s"
                    shift
                ;;
                --reboot|-r)
                    ushutdown="r"
                    shift
                ;;
                -c)
                    commitFlakeLock=1
                    shift
                ;;
                -C)
                    commitFlakeLock=0
                    shift
                ;;
                --)
                    shift
                    break
                ;;
                *)
                    break
                ;;
            esac
        done
    fi

    __keep-sudo-alive

    if [ -z "$FLAKE_PATH" ]; then
        if ! sudo nix-channel --update; then
            echo "Failed to update channel..."
            return 1
        fi
    else
        if ! sudo nix flake update --flake "$FLAKE_PATH"; then
            echo "Failed to update flake..."
            return 1
        fi
    fi

    if ! rebuild "$action" "$@" ; then
        __rollbackChannelOrFlake
        return 1
    elif [ "$commitFlakeLock" = 1 ]; then
        __commitFlakeLock
    fi

    case "$ushutdown" in
        s)
            shutdown now
        ;;
        r)
            reboot
        ;;
    esac
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
        esac
    fi

    if [ -n "$1" ]; then
        case "$1" in
            --help|-h)
                __rebuildHelp
                return 0
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

    if [ -z "$FLAKE_PATH" ]; then
        if where nh &> /dev/null; then
            if ! nh os "$action" -f '<nixpkgs/nixos>' "$@"; then
                return 1
            fi
        else
            if ! sudo nixos-rebuild "$action" "$@"; then
                return 1
            fi
        fi
    else
        if where nh &> /dev/null; then
            if ! nh os "$action" "$FLAKE_PATH" "$@"; then
                return 1
            fi
        else
            if ! sudo nixos-rebuild "$action" --flake "$FLAKE_PATH" "$@"; then
                return 1
            fi
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

__upgradeHelp() {
    echo "usage: upgrade [action] [options]"
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
    echo "    -c             Commit the flake.lock on successful upgrade"
    echo "    -C             Do not commit the flake.lock"
    echo "    --help -h      Show this help"
    echo "    --             Does nothing, but all arguments after this are passed to rebuild"
    echo
    echo "additional arguments are passed to the rebuild command"
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
    sudo -k
}

__rollbackChannelOrFlake() {
    if [ -z "$FLAKE_PATH" ]; then
        nix-channel-rollback
    else
        cd "$FLAKE_PATH" || return 1
        git restore flake.lock || return 1
        cd - > /dev/null || return 1
    fi
}

__commitFlakeLock() {
    if [ -z "$FLAKE_PATH" ]; then
        return 1
    fi

    cd "$FLAKE_PATH" || return 1
    git add flake.lock || return 1
    git commit -m "bump $(git rev-parse)/flake.lock" || return 1
    git push || return 1
    cd - > /dev/null || return 1
}
