#!/bin/bash

set -o nounset -o pipefail -o errexit

GIT_DIR=$(git rev-parse --git-dir)
HOOKS_DIR=$GIT_DIR/hooks

SCRIPT_DIR=$(readlink -f "$0" | xargs dirname)
ln -s "$SCRIPT_DIR/append-document-stats" "$HOOKS_DIR/prepare-commit-msg"
