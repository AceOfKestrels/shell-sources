#! /bin/bash

__maxgitcommitmessagelength=50

__checkCommitMessageLength() {
    if [ -z "$1" ]
    then
        return 0
    fi
  
    length=$(echo -n "$1" | wc -c)
    if [ "$length" -gt "$__maxgitcommitmessagelength" ]
    then
        echo "error: commit message exceeds 50 characters (was $length)"
        echo "use --force to ignore this constraint" 
        return 1
    fi

    return 0
}