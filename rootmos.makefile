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

QUICK ?= 1
ifeq ($(QUICK),1)
prereqs = %.tex $(AUX)/%.tex.wc $(AUX)/%.tex.build-info.lua | prepare
else
prereqs = %.tex $(AUX)/%.tex.wc $(AUX)/%.tex.build-info.lua FORCE | prepare
endif

%.pdf: $(call prereqs)
	$(LATEXMK) $<
%.final.pdf: $(call prereqs)
	$(LATEXMK) --jobname='%A.final' $<
%.draft.pdf: $(call prereqs)
	$(LATEXMK) --jobname='%A.draft' $<

.PRECIOUS: $(AUX)/%.wc
$(AUX)/%.wc: %
	$(TOOLS)/words.sh -o $@ $<

.PRECIOUS: $(AUX)/%.build-info.lua
$(AUX)/%.build-info.lua: %
	$(TOOLS)/build-info -l -o $@

$(AUX):
	@mkdir -p $@

prepare: deps $(LATEXMKRC) $(AUX)

$(LATEXMKRC):
	$(MAKEFILE_DIR)/latexmkrc.sh $(LATEXMKRC)

init: $(TEXHELP_DOTDIR)
reinit: deepclean init

$(TEXHELP_DOTDIR):
	wget -O- $(TEXHELP_URL) | bash -s -- -i

DEPS_FLAG = $(dir $(DEPS)).$(notdir $(DEPS)).texhelp
deps: init $(DEPS_FLAG)
$(DEPS_FLAG): $(wildcard $(DEPS))
	$(TEXHELP) -d $(MAKEFILE_DIR)/template/tl.deps
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
