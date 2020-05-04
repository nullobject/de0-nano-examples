.PHONY: build rom program clean

rom/blink.bin: rom/blink.asm
	z80asm rom/blink.asm -o rom/blink.bin

rom/blink.mif: rom/blink.bin
	srec_cat rom/blink.bin -binary -o rom/blink.mif -mif -output_block_size=16

build: rom/blink.mif
	quartus_sh --flow compile z80

rom: rom/blink.mif
	quartus_cdb --update_mif z80
	quartus_asm z80

program:
	quartus_pgm -m jtag -c 1 -o "p;output_files/z80.sof@1"

clean:
	rm -rf db incremental_db output_files rom
