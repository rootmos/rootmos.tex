ROOT ?= $(shell pwd)
AUX ?= $(ROOT)/aux

TEXHELP_URL ?= https://raw.githubusercontent.com/rootmos/texhelp/refs/heads/master/texhelp
export TEXHELP_DOTDIR ?= $(ROOT)/.texhelp
export TEXHELP := $(TEXHELP_DOTDIR)/bin/texhelp

draft: $(foreach doc, $(DOCUMENTS), $(doc).draft.pdf)
final: $(foreach doc, $(DOCUMENTS), $(doc).final.pdf)
all: $(foreach doc, $(DOCUMENTS), $(foreach type, draft final, $(doc).$(type).pdf))
.PHONY: all
.PHONY: draft final

MAKEFILE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
LATEXMKRC = $(MAKEFILE_DIR)/latexmkrc
LATEXMK = $(TEXHELP) -m -- -r $(LATEXMKRC) -pdflua -auxdir=$(AUX)

.PHONY: FORCE
%.pdf: %.tex $(LATEXMKRC) FORCE
	$(LATEXMK) $<
%.final.pdf: %.tex $(LATEXMKRC) FORCE
	$(LATEXMK) --jobname='%A.final' $<
%.draft.pdf: %.tex $(LATEXMKRC) FORCE
	$(LATEXMK) --jobname='%A.draft' $<

init: $(TEXHELP_DOTDIR) $(LATEXMKRC)
reinit: deepclean init

$(LATEXMKRC):
	$(MAKEFILE_DIR)/latexmkrc.sh $(LATEXMKRC)

$(TEXHELP_DOTDIR):
	wget -O- $(TEXHELP_URL) | sh -s -- -i

deps: init $(ROOT)/tl.deps
	$(TEXHELP) -d

update: init
	$(TEXHELP) -u

clean:
	rm -rf $(AUX)
	$(TEXHELP) -z

deepclean:
	rm -rf $(AUX)
	$(TEXHELP) -Z

.PHONY: init reinit
.PHONY: deps update
.PHONY: clean deepclean
