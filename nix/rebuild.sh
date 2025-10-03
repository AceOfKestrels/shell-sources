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
    action="boot"
    ushutdown="R"
    commitFlakeLock=0

    if [ -n "$1" ]; then
        case "$1" in
            switch|boot|test)
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
                --reload|-R)
                    ushutdown="R"
                    shift
                ;;
                --commit|-c)
                    commitFlakeLock=1
                    shift
                ;;
                --no-commit|-C)
                    commitFlakeLock=0
                    shift
                ;;
                --pull|-p)
                    upull=1
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

    if [ "$upull" = 1 ]; then
        if ! __pullConfig; then
            echo "upgrade: ${F_FG_RED}fatal${F_RESET}: failed to pull config"
            return 1
        fi
    fi

    if [ -z "$FLAKE_PATH" ]; then
        if ! sudo nix-channel --update; then
            echo "upgrade: ${F_FG_RED}fatal${F_RESET}: failed to update channel"
            return 1
        fi
    else
        if ! sudo nix flake update --flake "$FLAKE_PATH"; then
            echo -e "upgrade: ${F_FG_RED}fatal${F_RESET}: failed to update flake.lock"
            return 1
        fi
    fi

    if ! rebuild "$action" "$@" ; then
        __rollbackChannelOrFlake
        return 1
    elif ! [ "$action" = "test" ] & [ "$commitFlakeLock" = 1 ]; then
        __commitFlakeLock
    fi

    case "$ushutdown" in
        s)
            shutdown now
        ;;
        r)
            reboot
        ;;
        R)
            exec "$SHELL"
        ;;
    esac
}

rebuild() {
    action="switch"
    shutdown=""
    if [ -n "$1" ]; then
        case "$1" in
            switch|boot|test)
                action="$1"
                shift
            ;;
        esac
    fi

    if [ -n "$1" ]; then
        for arg in "$@"; do
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
                --reload|-R)
                    shutdown=R
                    shift
                ;;
                --pull|-p)
                    pull=1
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

    if [ "$pull" = 1 ]; then
        if ! __pullConfig; then
            echo "rebuild: ${F_FG_RED}fatal${F_RESET}: failed to pull config"
            return 1
        fi
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
        R)
            exec "$SHELL"
        ;;
    esac
}

__upgradeHelp() {
    echo -e "${F_FG_BLUE}usage${F_RESET}: upgrade [action] [options]"
    echo
    echo -e "update the channels or flake then rebuild the system"
    echo -e "uses nh if available, otherwise defaults to nixos-rebuild"
    echo
    echo -e "${F_FG_BLUE}actions${F_RESET}:"
    echo -e "    ${F_FG_YELLOW}switch${F_RESET} | ${F_FG_YELLOW}boot${F_RESET} | ${F_FG_YELLOW}test${F_RESET}"
    echo
    echo -e "${F_FG_BLUE}options${F_RESET}:"
    echo -e "    ${F_FG_YELLOW}--shutdown -s  ${F_RESET}Shutdown afterwards"
    echo -e "    ${F_FG_YELLOW}--reboot -r    ${F_RESET}Reboot afterwards"
    echo -e "    ${F_FG_YELLOW}--reload -R    ${F_RESET}Reload the shell afterwards"
    echo -e "    ${F_FG_YELLOW}--commit -c    ${F_RESET}Commit the flake.lock on successful upgrade"
    echo -e "    ${F_FG_YELLOW}--no-commit -C ${F_RESET}Do not commit the flake.lock"
    echo -e "    ${F_FG_YELLOW}--pull -p      ${F_RESET}Perform a git pull before rebuilding"
    echo -e "    ${F_FG_YELLOW}--help -h      ${F_RESET}Show this help"
    echo -e "    ${F_FG_YELLOW}--             ${F_RESET}Does nothing, but all arguments after this are passed to rebuild"
    echo
    echo -e "additional arguments are passed to the rebuild command"
}

__rebuildHelp() {
    echo "${F_FG_BLUE}usage${F_RESET}: rebuild [action] [options]"
    echo
    echo "rebuild the system configuration"
    echo "uses nh if available, otherwise defaults to nixos-rebuild"
    echo
    echo "${F_FG_BLUE}actions${F_RESET}:"
    echo "    ${F_FG_YELLOW}switch${F_RESET} | ${F_FG_YELLOW}boot${F_RESET} | ${F_FG_YELLOW}test${F_RESET}"
    echo
    echo "${F_FG_BLUE}options${F_RESET}:"
    echo "    ${F_FG_YELLOW}--shutdown -s  ${F_RESET}Shutdown afterwards"
    echo "    ${F_FG_YELLOW}--reboot -r    ${F_RESET}Reboot afterwards"
    echo "    ${F_FG_YELLOW}--reload -R    ${F_RESET}Reload the shell afterwards"
    echo "    ${F_FG_YELLOW}--pull -p      ${F_RESET}Perform a git pull before rebuilding"
    echo "    ${F_FG_YELLOW}--help -h      ${F_RESET}Show this help"
    echo "    ${F_FG_YELLOW}--             ${F_RESET}Does nothing, but all arguments after this are passed to rebuild"
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
        cd "$FLAKE_PATH" > /dev/null || return 1
        git restore flake.lock || return 1
        cd - > /dev/null || return 1
    fi
}

__commitFlakeLock() {
    if [ -z "$FLAKE_PATH" ]; then
        return 1
    fi

    cd "$FLAKE_PATH" >/dev/null || return 1
    git add flake.lock || return 1

    __createFlakeCommit

    git push || return 1
    cd - > /dev/null || return 1
}

__createFlakeCommit() {
    flakePath=$(git rev-parse --show-prefix | sed 's:/*$::')
    user="${flakePath%%/*}"
    flake="${flakePath##*/}"

    if ! where jq >/dev/null; then
        git commit -m "[$user] bump $flake" || return 1
        return
    fi

    nixpkgs=$(jq -r '.nodes.nixpkgs.locked.rev[0:7]' flake.lock)
    updatedInputs=$(jq -r '.nodes | to_entries[] | select(.value.locked.rev != null) | "\(.key) \(.value.locked.rev[0:7])"' flake.lock)

    git commit -m "[$user] bump $flake to nixpkgs $nixpkgs" -m "$updatedInputs" || return 1
}

__pullConfig() {
    configPath=/etc/nixos/nixos-config
    if [ -n "$NIXOS_CONFIG_PATH" ]; then
        configPath="$NIXOS_CONFIG_PATH"
    fi

    cd "$configPath" >/dev/null || return 1
    git pull --ff-only || return 1
    cd - >/dev/null || return 1
}