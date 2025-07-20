#! /bin/bash

if ! where git &>/dev/null ; then
    return 0
fi

alias gs='git status'
alias gco='git checkout'
alias gr='git rebase'
alias gf='git fetch'
alias gpl='git pull'
alias pfusch='gp -f'

if [ -n "$BASH_VERSION" ]; then
    __git_complete gp _git_checkout
    __git_complete gco _git_checkout
    __git_complete gr _git_checkout
    __git_complete gri _git_checkout
    __git_complete ga _git_add
    __git_complete gre _git_add
    __git_complete gca _git_add
    __git_complete gac _git_add
fi

gl() {
    if [ -z "$1" ]
    then
        git log --oneline --graph --all "$@"
        return 1
    fi

    arg="$1"
    shift

    case "$arg" in
        -h|--help)
            echo "gl: \"git log\""
            echo "usage: \"gl <option>\""
            echo ""
            echo "options:"
            echo "  -h --help       Display this help"
            echo "  -v --verbose    Default git log"
            echo ""
            echo "additional arguments will be passed to git log"
        ;;
        -v|--verbose)
            git log "$@"
        ;;
        *)
            git log --oneline --graph --all "$arg" "$@"
        ;;
    esac
}

ga() {
    git add "${@:--A}"
}

gc() {
    if [ -z "$1" ]; then
        echo "error: commit message requires a value"
        echo ""
        echo "gc: \"git commit with message\""
        echo "usage: \"gc [commit message]\""
        return 1
    fi

    message="$1"
    shift
    
    __checkCommitMessageLength "$message"

    git commit -m "$message"
}

gac() {
    if [ -z "$1" ]; then
        echo "error: commit message requires a value"
        echo ""
        echo "gac: \"git stage and commit\""
        echo "usage: \"gac [commit message] <options> <files to stage>\""
        echo ""
        echo "options:"
        echo "  -f --force  Ignore the length limit of commit messages"
        return 1
    fi

    message="$1"
    shift

    if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
        shift
        ga "$@"
        gc "$message" -f
        return 1
    fi
    
    __checkCommitMessageLength "$message"

    ga "$@"
    git commit -m "$message"
}

gca() {
    changes=$(git diff --stat -- "${@:-.}")
    
    if [ -z "$changes" ]; then
        git status
        return 1
    fi

    echo "[$(git rev-parse --abbrev-ref HEAD) $(git log -1 --pretty=%h)] $(git log -1 --pretty=%s)"
    echo "$changes"
    ga "$@"
    error_message=$(git commit --amend --no-edit 2>&1 > /dev/null)
    
    if [ -n "$error_message" ]; then
        echo "$error_message"
        return 1
    fi
}

gri() {
    if [ -z "$1" ] 
    then
        echo "error: count requires a value"
        echo ""
        echo "gri: \"git rebase interactive (from HEAD)\""
        echo "usage: \"gri <count> [options]\""
        echo "options:"
        echo "  -v --verbatim  Take the edited commit message verbatim. Allows for the message to start with #. Remember to remove the additional lines in the rebase editor!"
        return 1
    fi

    if [ "$2" = "-v" ] || [ "$2" = "--verbatim" ]; then
        git -c commit.cleanup=verbatim rebase -i HEAD~"$1"
    else
        git rebase -i HEAD~"$1"
    fi
}

gre() {
    git restore "${@:-.}"
}

gp() {
    if [ -n "$1" ] || git rev-parse --abbrev-ref @\{u\} >/dev/null 2>&1; then
        git push "$@"
        return 0
    fi

    branch_name=$(git rev-parse --abbrev-ref HEAD)
    git push -u origin "$branch_name"
}

gitinit() {
    git init
    
    if [ ! -f .gitignore ]; then
        echo "Creating default gitignore"
        {
            echo ".vs/"
            echo ".idea/"
            echo "obj/"
            echo "bin/"
        } > .gitignore
    fi

}

if [ -z "$GIT_BROWSER" ]; then
    GIT_BROWSER=firefox
    GIT_BROWSER_ARGS=""
fi

gb() {
    if [ -z "$GIT_BROWSER" ]; then
        echo "No browser configured. You must set GIT_BROWSER to a value."
	return 1
    fi

    if ! git status --porcelain > /dev/null; then
	    return 1
    fi

    if [ -z "$GIT_BROWSER_ARGS" ]; then
        $GIT_BROWSER "$(git remote get-url origin)"
    else
        $GIT_BROWSER "$GIT_BROWSER_ARGS" "$(git remote get-url origin)"
    fi
}

gprune() {
    git fetch --prune

    remote="$(git remote)"
    
    delete=false
    if [ "$1" = "-d" ] || [ "$1" = "--delete" ]; then
        delete=true
    fi

    if [ "$delete" = "false" ]; then 
        echo "The following branches have no remote:"
    fi

    git branch -vv | while read -r branch; do
        if echo "$branch" | grep -q -E "^\*.+"; then # current branch
            continue
        fi

        if ! echo "$branch" | grep -q -E ".+\[$remote/.+: gone\].+"; then # !upstream gone
            if echo "$branch" | grep -q -E ".+\[$remote/.+\].+"; then # upstream exists
                continue
            fi
        fi

        branch="$(echo "$branch" | cut -d ' ' -f 1)"

        if [ "$delete" = "true" ]; then
            git branch -D "$branch"
        else
            echo "    $branch"
        fi
    done

    if [ "$delete" = "false" ]; then 
        echo
        echo "Use \"gprune --delete\" to delete"
    fi
}