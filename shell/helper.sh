#! /bin/bash

if [ -z "$GIT_COMMIT_MESSAGE_MAX_LENGTH" ]; then
    GIT_COMMIT_MESSAGE_MAX_LENGTH=50
fi

__checkCommitMessageLength() {
    if [ -z "$1" ]
    then
        return
    fi
  
    length=$(echo -n "$1" | wc -c)
    if [ "$length" -gt "$GIT_COMMIT_MESSAGE_MAX_LENGTH" ]
    then
        echo -e "${F_FG_YELLOW}warning${F_RESET}: commit message exceeds $GIT_COMMIT_MESSAGE_MAX_LENGTH characters (was $length)"
    fi
}