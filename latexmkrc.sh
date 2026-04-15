#!/bin/bash

set -o nounset -o pipefail -o errexit

SCRIPT_DIR=$(readlink -f "$0" | xargs dirname)
ROOT=${ROOTMOS_TEX-$SCRIPT_DIR}

TARGET=${1-.latexmkrc}

cat <<EOF >>"$TARGET"
ensure_path('TEXINPUTS', '$ROOT/texmf//');
ensure_path('LUAINPUTS', '$ROOT/texmf//');
EOF
