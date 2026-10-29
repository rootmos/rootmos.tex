set -o nounset -o pipefail -o errexit

go() {
    #tests/run go.lua
    #make -C tests
    #(cd template; make aux/sandbox.tex.wc && aux/sandbox.tex.wc)
    (
        cd template

        # shellcheck source=/dev/null
        . .texhelp/activate

        #make clean
        #make abbrev.draft.pdf QUICK=0
        make sections.draft.pdf QUICK=0

        #texhelp -e texcount sandbox.tex
        #../tools/words.sh skeleton.tex
    )
}
