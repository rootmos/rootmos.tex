set -o nounset -o pipefail -o errexit

go() {
    #lua go.lua
    template
    #tests/run go.lua
    #make -C tests
}

template() {
    (
        cd template

        # shellcheck source=/dev/null
        . .texhelp/activate

        export QUICK=

        #make clean
        #make abbrev.draft.pdf
        #make apa.draft.pdf
        #make sections.draft.pdf sections.final.pdf
        #make tlp.draft.pdf
        #make quote.draft.pdf quote.final.pdf
        #make debug.draft.pdf
        make a4.draft.pdf a4.final.pdf

        #texhelp -e texcount sandbox.tex
        #git show HEAD^:./apa.tex |  ../tools/words -fstrict
    )
}
