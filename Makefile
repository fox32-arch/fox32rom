FOX32ASM ?= fox32asm
OKAMERON ?= $(CURDIR)/meta/okameron/okameron.lua
LUA ?= lua

all: fox32.rom

OKAMERON_FILES := \
	RYFS.okm

fox32.rom: $(wildcard *.asm */*.asm) $(OKAMERON_FILES)
	$(LUA) $(OKAMERON) -arch=fox32 $(OKAMERON_FILES) > okameron.asm
	$(FOX32ASM) main.asm $@
	$(RM) okameron.asm

clean:
	$(RM) fox32.rom
