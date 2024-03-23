FOX32ASM = ../fox32asm/target/release/fox32asm
OKAMERON = $(CURDIR)/meta/okameron/okameron.lua

all: fox32.rom

OKAMERON_FILES := \
	RYFS.okm

fox32.rom: $(wildcard *.asm */*.asm) $(OKAMERON_FILES)
	lua $(OKAMERON) -arch=fox32 $(OKAMERON_FILES) > okameron.asm
	$(FOX32ASM) main.asm $@
	rm okameron.asm

clean:
	rm -f fox32.rom
