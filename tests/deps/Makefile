CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TOOLS ?= $(realpath $(CURRENT_DIR)/../../tools)
FETCH ?= $(TOOLS)/fetch
export FETCH_MANIFEST ?= $(CURRENT_DIR)/deps.json

all: luaunit

luaunit: luaunit.zip
	mkdir -p $@
	bsdtar xvf $< --strip-components=1 -C $@ '*/luaunit.lua' '*/LICENSE.txt'

luaunit.zip: $(FETCH_MANIFEST)
	$(FETCH) download $@

deepclean:
	rm -rf luaunit.zip luaunit

.PHONY: all
.PHONY: deepclean
