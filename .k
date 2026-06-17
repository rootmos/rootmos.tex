go() {
    #tests/run go.lua
    #make -C tests
    #(cd template; make aux/sandbox.tex.wc && aux/sandbox.tex.wc)
    (
        set -o errexit
        cd template
        #make clean skeleton.draft.pdf QUICK=0
        make skeleton.draft.pdf QUICK=0
        #. .texhelp/activate
        #texhelp -e texcount sandbox.tex
        #../tools/words.sh skeleton.tex
    )
}
