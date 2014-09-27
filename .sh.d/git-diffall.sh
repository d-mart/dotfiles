#!/bin/bash -e
# Copyright 2010, Tim Henigan <tim.henigan@gmail.com>
#
# Perform a directory diff between commits in the repository using
# the external diff tool specified in the 'diff.tool' configuration
# option.

# The git-diffall script provides a directory based diff mechanism
# for git.  The script relies on the diff.tool configuration option
# to determine what diff viewer is used.
# 
# This script is compatible with all the forms used to specify a
# range of revisions to diff:
# 
#   1) git diffall: shows diff between working tree and staged changes
#   2) git diffall --cached [<commit>]: shows diff between staged changes and HEAD (or other named commit)
#   3) git diffall <commit>: shows diff between working tree and named commit
#   4) git diffall <commit> <commit>: show diff between two named commits
#   5) git diffall <commit>..<commit>: same as above
#   6) git diffall <commit>...<commit>: show the changes on the branch containing and up to the second , starting at a common ancestor of both <commit>
# 
# Note: all forms take an optional path limiter [--] [<path>*]
# 
# This script is based on an example provided by Thomas Rast on the Git list [1]:
# [1] http://thread.gmane.org/gmane.comp.version-control.git/124807

# Copied from https://github.com/dbingham/git-diffall/blob/de75a289f9240315c8249105830e1464a0b8c45f/git-diffall

USAGE='[--cached] <commit>{0,2} -- <path>*

--cached Compare to the index rather than the working tree
'

SUBDIRECTORY_OK=1
. "$(git --exec-path)/git-sh-setup"

if [ -z $(git config --get diff.tool) ]; then
echo "Error: The 'diff.tool' configuration option must be set."
    usage
fi

start_dir=$(pwd)

# needed to access tar utility
cdup=$(git rev-parse --show-cdup) &&
cd "$cdup" || {
    echo >&2 "Cannot chdir to $cdup, the toplevel of the working tree"
    exit 1
}

# mktemp is not available on all platforms (missing from msysgit)
# Use a hard-coded tmp dir if it is not available
if [ -z $(which mktemp) ]; then
tmp=/tmp/git-diffall-tmp
else
tmp="$(mktemp -d -t tmp.XXXXXX)"
fi
mkdir -p "$tmp"

left=
right=
paths=
path_sep=
compare_staged=
common_ancestor=
left_dir=
right_dir=

while test $# != 0; do
case "$1" in
    -h|--h|--he|--hel|--help)
        usage
        ;;
    --cached)
        compare_staged=1
        ;;
    --)
        path_sep=1
        ;;
    -*)
        echo Invalid option: "$1"
        usage
        ;;
    *)
        # could be commit, commit range or path limiter
        case "$1" in
        *...*)
            left=${1%...*}
            right=${1#*...}
            common_ancestor=1
            ;;
        *..*)
            left=${1%..*}
            right=${1#*..}
            ;;
        *)
            if [ -n "$path_sep" ]; then
if [ -z "$paths" ]; then
paths=$1
                else
paths="$paths $1"
                fi
elif [ -z "$left" ]; then
left=$1
            elif [ -z "$right" ]; then
right=$1
            else
if [ -z "$paths" ]; then
paths=$1
                else
paths="$paths $1"
                fi
fi
            ;;
        esac
        ;;
    esac
shift
done

# Determine the set of files which changed
if [ -n "$left" ] && [ -n "$right" ]; then
left_dir="cmt-`git rev-parse --short $left`"
    right_dir="cmt-`git rev-parse --short $right`"

    if [ -n "$compare_staged" ]; then
usage
    elif [ -n "$common_ancestor" ]; then
git diff --name-only "$left"..."$right" -- "$paths" > "$tmp"/filelist
    else
git diff --name-only "$left" "$right" -- "$paths" > "$tmp"/filelist
    fi
elif [ -n "$left" ]; then
left_dir="cmt-`git rev-parse --short $left`"

    if [ -n "$compare_staged" ]; then
right_dir="staged"
        git diff --name-only --cached "$left" -- "$paths" > "$tmp"/filelist
    else
right_dir="working_tree"
        git diff --name-only "$left" -- "$paths" > "$tmp"/filelist
    fi
else
left_dir="HEAD"

    if [ -n "$compare_staged" ]; then
right_dir="staged"
        git diff --name-only --cached -- "$paths" > "$tmp"/filelist
    else
right_dir="working_tree"
        git diff --name-only -- "$paths" > "$tmp"/filelist
    fi
fi

# Exit immediately if there are no diffs
if [ ! -s "$tmp"/filelist ]; then
exit 0
fi

# Create the named tmp directories that will hold the files to be compared
mkdir -p "$tmp"/"$left_dir" "$tmp"/"$right_dir"

# Populate the tmp/right_dir directory with the files to be compared
if [ -n "$right" ]; then
while read name; do
ls_list=$(git ls-tree $right $name)
        if [ -n "$ls_list" ]; then
mkdir -p "$tmp"/"$right_dir"/"$(dirname "$name")"
            git show "$right":"$name" > "$tmp"/"$right_dir"/"$name" || true
fi
done < "$tmp"/filelist
elif [ -n "$compare_staged" ]; then
while read name; do
ls_list=$(git ls-files -- $name)
        if [ -n "$ls_list" ]; then
mkdir -p "$tmp"/"$right_dir"/"$(dirname "$name")"
            git show :"$name" > "$tmp"/"$right_dir"/"$name"
        fi
done < "$tmp"/filelist
else
if [ -n "$(which gnutar)" ]; then
gnutar --ignore-failed-read -c -T "$tmp"/filelist | (cd "$tmp"/"$right_dir" && gnutar -x)
    else
tar --ignore-failed-read -c -T "$tmp"/filelist | (cd "$tmp"/"$right_dir" && tar -x)
    fi
fi

# Populate the tmp/left_dir directory with the files to be compared
while read name; do
if [ -n "$left" ]; then
ls_list=$(git ls-tree $left $name)
        if [ -n "$ls_list" ]; then
mkdir -p "$tmp"/"$left_dir"/"$(dirname "$name")"
            git show "$left":"$name" > "$tmp"/"$left_dir"/"$name" || true
fi
else
if [ -n "$compare_staged" ]; then
ls_list=$(git ls-tree HEAD $name)
            if [ -n "$ls_list" ]; then
mkdir -p "$tmp"/"$left_dir"/"$(dirname "$name")"
                git show HEAD:"$name" > "$tmp"/"$left_dir"/"$name"
                fi
else
mkdir -p "$tmp"/"$left_dir"/"$(dirname "$name")"
                    git show :"$name" > "$tmp"/"$left_dir"/"$name"
        fi
fi
done < "$tmp"/filelist

cd "$tmp"
$(git config --get diff.tool) "$left_dir" "$right_dir"

# On exit, remove the tmp directory
cleanup () {
    cd "$start_dir"
    rm -rf "$tmp"
}

trap cleanup EXIT


