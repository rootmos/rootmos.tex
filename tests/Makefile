.PHONY: all
all: deps
	./run main.lua
	./run abbrev.lua

.PHONY: deps
deps:
	$(MAKE) -C deps
	$(MAKE) -C ../template init
