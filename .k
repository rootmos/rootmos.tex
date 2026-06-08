go() {
    #tests/run go.lua
    #make -C tests
    #(cd template; make aux/sandbox.tex.wc && aux/sandbox.tex.wc)
    (
        set -o errexit
        cd template
        make QUICK=0
        #. .texhelp/activate
        #texhelp -e texcount sandbox.tex
        #../tools/words.sh sandbox.tex
    )
}
