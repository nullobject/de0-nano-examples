.PHONY: build program clean

build:
	quartus_sh --flow compile sdram

program:
	quartus_pgm -m jtag -c 1 -o "p;output_files/sdram.sof@1"

clean:
	rm -rf db incremental_db output_files
