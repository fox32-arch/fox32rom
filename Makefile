FOX32ASM ?= fox32asm
OKAMERON ?= $(CURDIR)/meta/okameron/okameron.lua
LUA ?= lua
XXD ?= xxd
INSTALL ?= install -D
PREFIX ?= /usr/local

all: fox32.rom fox32rom.h

OKAMERON_FILES := \
	RYFS.okm

fox32.rom: $(wildcard *.asm */*.asm) $(OKAMERON_FILES)
	$(LUA) $(OKAMERON) -arch=fox32 $(OKAMERON_FILES) > okameron.asm
	$(FOX32ASM) main.asm $@
	$(RM) okameron.asm

fox32rom.h: fox32.rom
	$(XXD) -i $^ | sed s/fox32_rom/fox32rom/ > $@

install: fox32.rom fox32rom.h
	$(INSTALL) -m644 fox32.rom /usr/local/libexec/fox32.rom
	$(INSTALL) -m644 fox32rom.h /usr/local/include/fox32rom.h

clean:
	$(RM) fox32.rom fox32rom.h
