go() {
    #tests/run go.lua
    #make -C tests
    #(cd template; make aux/sandbox.tex.wc && aux/sandbox.tex.wc)
    (
        set -o errexit
        cd template
        . .texhelp/activate
        texhelp -e texcount sandbox.tex
        ../tools/words.sh sandbox.tex
    )
}
