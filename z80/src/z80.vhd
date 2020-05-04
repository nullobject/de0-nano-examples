-- Copyright (c) 2019 Josh Bassett
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity z80 is
  port (
    clk : in std_logic;
    key : in std_logic_vector(1 downto 0);
    led : out std_logic_vector(7 downto 0)
  );
end z80;

architecture arch of z80 is
  -- clock enable
  signal cen : std_logic;

  -- cpu reset
  signal reset : std_logic;

  -- address bus
  signal cpu_addr	: unsigned(15 downto 0);

  -- data bus
  signal cpu_din	: std_logic_vector(7 downto 0);
  signal cpu_dout	: std_logic_vector(7 downto 0);

  -- i/o request: the address bus holds a valid address for an i/o read or
  -- write operation
  signal cpu_ioreq_n : std_logic;

  -- memory request: the address bus holds a valid address for a memory read or
  -- write operation
  signal cpu_mreq_n : std_logic;

  -- refresh memory: the CPU asserts this signal when it is refreshing
  -- a dynamic memory address
  signal cpu_rfsh_n : std_logic;

  -- read: ready to read data from the data bus
  signal cpu_rd_n : std_logic;

  -- write: the data bus contains a byte to write somewhere
  signal cpu_wr_n : std_logic;

  -- chip select signals
  signal prog_cs : std_logic;
  signal led_cs : std_logic;

  -- registers
  signal led_reg : std_logic_vector(7 downto 0);
begin
  clock_divider : entity work.clock_divider
  generic map (DIVISOR => 50)
  port map (clk => clk, cen => cen);

  -- Generate a reset pulse after powering on, or when KEY0 is pressed.
  --
  -- The Z80 needs to be reset after powering on, otherwise it may load garbage
  -- data from the address and data buses.
  reset_gen : entity work.reset_gen
  port map (
    clk  => clk,
    rin  => not key(0),
    rout => reset
  );

  prog_rom : entity work.single_port_rom
  generic map(
    ADDR_WIDTH => 8,
    DATA_WIDTH => 8,
    INIT_FILE  => "rom/blink.mif"
  )
  port map(
    clk  => clk,
    cs   => prog_cs and cpu_rfsh_n and not cpu_rd_n,
    addr => cpu_addr(7 downto 0),
    dout => cpu_din
  );

  cpu : entity work.T80s
  port map(
    RESET_n     => not reset,
    CLK         => clk,
    CEN         => cen,
    INT_n       => '1',
    M1_n        => open,
    MREQ_n      => cpu_mreq_n,
    IORQ_n      => cpu_ioreq_n,
    RD_n        => cpu_rd_n,
    WR_n        => cpu_wr_n,
    RFSH_n      => cpu_rfsh_n,
    HALT_n      => open,
    BUSAK_n     => open,
    unsigned(A) => cpu_addr,
    DI          => cpu_din,
    DO          => cpu_dout
  );

  set_led_register : process (clk)
  begin
    if rising_edge(clk) then
      if led_cs = '1' and cpu_wr_n = '0' then
        led_reg <= cpu_dout;
      end if;
    end if;
  end process;

  prog_cs <= '1' when cpu_addr >= x"0000" and cpu_addr <= x"7fff" else '0';
  led_cs  <= '1' when cpu_addr = x"8000" else '0';

  led <= led_reg;
end arch;
