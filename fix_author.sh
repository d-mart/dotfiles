#!/usr/bin/env bash

DESIRED_EMAIL="dm@dmartinez.net"
DESIRED_AUTHOR="d-mart"

#git filter-branch --env-filter 'if [ "$GIT_AUTHOR_EMAIL" -ne "$DESIRED_EMAIL" ]; then
#     GIT_AUTHOR_EMAIL=$DESIRED_EMAIL;
#     GIT_AUTHOR_NAME="$DESIRED_AUTHOR";
#     GIT_COMMITTER_EMAIL=$DESIRED_EMAILL;
#     GIT_COMMITTER_NAME="$DESIRED_AUTHOR"; fi' -- --all

git filter-branch --env-filter '
     GIT_AUTHOR_EMAIL=dm@dmartinez.net;
     GIT_AUTHOR_NAME="d-mart";
     GIT_COMMITTER_EMAIL=dm@dmartinez.net;
     GIT_COMMITTER_NAME="d-mart";' -- --all
