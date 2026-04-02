OKAMERON ?= $(CURDIR)/meta/okameron/okameron.lua
LUA ?= lua
XXD ?= xxd
INSTALL ?= install -D
PREFIX ?= /usr/local

ifeq (, $(shell which fox32asm))
FOX32ASM ?= ../fox32asm/target/release/fox32asm
else
FOX32ASM ?= fox32asm
endif

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
	$(INSTALL) -m644 fox32.rom $(DESTDIR)/usr/local/libexec/fox32.rom
	$(INSTALL) -m644 fox32rom.h $(DESTDIR)/usr/local/include/fox32rom.h

clean:
	$(RM) fox32.rom fox32rom.h
