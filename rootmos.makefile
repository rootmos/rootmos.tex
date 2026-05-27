CURRENT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export ROOT ?= $(CURRENT_DIR)
AUX ?= $(ROOT)/aux
OUTDIR ?= $(ROOT)

DEPS = $(ROOT)/tl.deps

TEXHELP_URL ?= https://raw.githubusercontent.com/rootmos/texhelp/refs/heads/master/texhelp
export TEXHELP_DOTDIR ?= $(ROOT)/.texhelp
export TEXHELP := $(TEXHELP_DOTDIR)/bin/texhelp

draft: $(foreach doc, $(DOCUMENTS), $(doc).draft.pdf)
final: $(foreach doc, $(DOCUMENTS), $(doc).final.pdf)
all: $(foreach doc, $(DOCUMENTS), $(foreach type, draft final, $(doc).$(type).pdf))
.PHONY: all
.PHONY: draft final

MAKEFILE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLS = $(MAKEFILE_DIR)/tools
LATEXMKRC = $(MAKEFILE_DIR)/latexmkrc
LATEXMK = $(TEXHELP) -m -- -r $(LATEXMKRC) -pdflua -auxdir=$(AUX) -outdir=$(OUTDIR)

%.pdf: %.tex $(AUX)/%.tex.wc prepare
	$(LATEXMK) $<
%.final.pdf: %.tex $(AUX)/%.tex.wc prepare
	$(LATEXMK) --jobname='%A.final' $<
%.draft.pdf: %.tex $(AUX)/%.tex.wc prepare
	$(LATEXMK) --jobname='%A.draft' $<

$(AUX)/%.tex.wc: %.tex
	$(TOOLS)/words.sh -o $@ $<

export BUILD_INFO = $(AUX)/build-info.lua
prepare: deps $(LATEXMKRC) $(BUILD_INFO)

$(BUILD_INFO): FORCE
	@mkdir -p $(dir $@)
	$(TOOLS)/build-info -l -o $@

$(LATEXMKRC):
	$(MAKEFILE_DIR)/latexmkrc.sh $(LATEXMKRC)

init: $(TEXHELP_DOTDIR)
reinit: deepclean init

$(TEXHELP_DOTDIR):
	wget -O- $(TEXHELP_URL) | bash -s -- -i

DEPS_FLAG = $(dir $(DEPS))/.$(notdir $(DEPS)).texhelp
deps: init $(DEPS_FLAG)
$(DEPS_FLAG): $(DEPS)
	$(TEXHELP) -d
	@touch $@

update: init
	$(TEXHELP) -u

clean:
	rm -rf $(AUX) .*.texhelp
	$(TEXHELP) -z

deepclean: clean
	$(TEXHELP) -Z

.PHONY: FORCE
.PHONY: prepare
.PHONY: init reinit
.PHONY: deps update
.PHONY: clean deepclean
