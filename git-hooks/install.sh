#!/bin/bash

set -o nounset -o pipefail -o errexit

GIT_DIR=$(git rev-parse --absolute-git-dir)
HOOKS_DIR=$GIT_DIR/hooks

SCRIPT_DIR=$(readlink -f "$0" | xargs dirname)
SRC="$SCRIPT_DIR/append-document-stats"
DST="$HOOKS_DIR/prepare-commit-msg"

if [[ -e $DST ]]; then
    if [[ $(readlink -f "$DST") != "$SRC" ]]; then
        echo 1>&2 "destination file already exists: $DST"
        exit 1
    fi
else
    ln -vs "$SRC" "$DST"
fi
