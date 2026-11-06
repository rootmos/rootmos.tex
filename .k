set -o nounset -o pipefail -o errexit

go() {
    #lua go.lua
    template
}

template() {
    (
        cd template

        # shellcheck source=/dev/null
        . .texhelp/activate

        export QUICK=

        #make clean
        make abbrev.draft.pdf
        #make sections.draft.pdf sections.final.pdf
        #make tlp.draft.pdf

        #texhelp -e texcount sandbox.tex
        #../tools/words.sh skeleton.tex
    )
}
