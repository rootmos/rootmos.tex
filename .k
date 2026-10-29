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

        #make clean
        #make abbrev.draft.pdf QUICK=0
        make sections.draft.pdf sections.final.pdf QUICK=0

        #texhelp -e texcount sandbox.tex
        #../tools/words.sh skeleton.tex
    )
}
