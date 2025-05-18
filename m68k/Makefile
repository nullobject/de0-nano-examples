PROG = display
PROG_C = rom/$(PROG).c
PROG_O = build/$(PROG).o
PROG_OUT = build/$(PROG).out
PROG_BIN = build/$(PROG).bin
PROG_HEX = build/$(PROG).hex
FAKE_HEX = build/rom.hex

SRC = $(wildcard hdl/*.v) $(wildcard lib/fx68k/*.v)

$(PROG_BIN): $(PROG_C) rom/linker_script.ld
	mkdir -p build
	m68k-linux-gnu-gcc -Wall -march=68000 -Os -fomit-frame-pointer -ffreestanding -nostdlib -nostartfiles -Wl,-Trom/linker_script.ld -o $@ $<

$(PROG_HEX): $(PROG_BIN)
	hexdump -v -e '2/1 "%02X" "\n"' $< > $@

build: build/display.hex
	quartus_sh --flow compile m68k

rom: build/display.hex
	quartus_cdb --update_mif m68k
	quartus_asm m68k

program:
	quartus_pgm -m jtag -c 1 -o "p;output_files/m68k.sof@1"

clean:
	rm -rf db incremental_db output_files rom/display.bin rom/display.mif

.PHONY: build rom program clean
.SECONDARY:
