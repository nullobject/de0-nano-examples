# DE0-Nano Examples

Some example circuits written in VHDL for [Terasic DE0-Nano FPGA board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=593).

## Prerequisites

The easiest way to build these circuits is using make:

    $ sudo apt install make

You will need to have the Quartus bin directory in your path, for example:

    PATH="/opt/intelFPGA_lite/19.1/quartus/bin:$PATH"

Some examples also require the GNU Z80 assembler to be installed:

    $ sudo apt install z80asm

## Getting Started

To build an example, change to the directory of the circuit and run make:

    $ cd counter
    $ make build program

## Examples

### Counter

This example defines a simple circuit to increment a counter every 100ms. The binary value of the counter is displayed on the LEDs.

### Z80

This example runs a small program on a Z80 softcore microprocessor to blink the LEDs.

Even though the [blink program](https://github.com/nullobject/de0-nano-examples/blob/master/z80/rom/blink.asm) is quite simple, the circuit must define the basic components of a computer in order to execute it. The circuit contains ROM, RAM, and a CPU.

### SDRAM

This example loads some values into the SDRAM, and then reads the values back out again, displaying them on the LEDs.
