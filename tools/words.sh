#!/bin/bash

set -o nounset -o pipefail -o errexit

TEXHELP=${TEXHELP-texhelp}

OUTPUT=
while getopts "o:-" OPT; do
    case $OPT in
        o) OUTPUT=$OPTARG ;;
        -) break ;;
        ?) exit 2 ;;
    esac
done
shift $((OPTIND-1))

TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT

cat <<'EOF' >"$TMP/opt"
%macro \pc [ignore]
%macro \tc [ignore]
%macro \tq [ignore,other]
%macro \bq [ignore,other]
%macro \pcin [ignore,ignore]
%macro \tcin [ignore,ignore]
%macro \bqin [ignore,ignore,other]
%macro \tqin [ignore,ignore,other]

%macro \todo [ignore]
%macro \todoi [ignore]
EOF

set +e
"$TEXHELP" -e texcount -opt="$TMP/opt" -1 -sum=1 "$1" 1>"$TMP/words" 2>"$TMP/stderr"
EC=$?
set -e
if [[ $EC -ne 0 ]]; then
    cat "$TMP/stderr" 1>&2
    exit $EC
else
    cat "$TMP/stderr" \
        | grep -v "^SUMWEIGHTS" \
        | grep -v "^Possible precedence problem between" \
        | cat 1>&2 || true
fi

if [[ -z $OUTPUT ]]; then
    cat "$TMP/words"
else
    cp "$TMP/words" "$OUTPUT"
fi
