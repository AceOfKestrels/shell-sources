#! /bin/bash

alias nix-store-query=__nixStoreQuery

__nixStoreQuery() {
    if [ -z "$1" ]; then
        echo "${F_FG_BLUE}usage${F_RESET}: nix-store-query <query> [options]"
        return 1
    fi
    
    case "$1" in
        -h|--help)
            __nixStoreQueryHelp
            return 1
        ;;
        *)
            query=$1
            shift
        ;;
    esac
    
    if [ -z "$1" ]; then
        nix-store --query /nix/store/*"$query"* || return 1
        return 0
    fi

    case "$1" in
        -h|--help)
            __nixStoreQueryHelp
            return 1
        ;;
        --referrers)
            args="--referrers"
        ;;
        *)
            echo "${F_FG_BLUE}usage${F_RESET}: nix-store-query <query> [options]"
            return 1
        ;;
    esac

    nix-store --query $args /nix/store/*"$query"* || return 1
}

__nixStoreQueryHelp() {
    echo -e "${F_FG_BLUE}usage${F_RESET}: nix-store-query <query> [options]"
    echo
    echo -e "query the nix store"
    echo
    echo -e "${F_FG_BLUE}options${F_RESET}:"
    echo -e "    ${F_FG_YELLOW}--referrers    ${F_RESET}List all files that reference <query>"
}