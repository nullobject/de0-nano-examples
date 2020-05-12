--   __   __     __  __     __         __
--  /\ "-.\ \   /\ \/\ \   /\ \       /\ \
--  \ \ \-.  \  \ \ \_\ \  \ \ \____  \ \ \____
--   \ \_\\"\_\  \ \_____\  \ \_____\  \ \_____\
--    \/_/ \/_/   \/_____/   \/_____/   \/_____/
--   ______     ______       __     ______     ______     ______
--  /\  __ \   /\  == \     /\ \   /\  ___\   /\  ___\   /\__  _\
--  \ \ \/\ \  \ \  __<    _\_\ \  \ \  __\   \ \ \____  \/_/\ \/
--   \ \_____\  \ \_____\ /\_____\  \ \_____\  \ \_____\    \ \_\
--    \/_____/   \/_____/ \/_____/   \/_____/   \/_____/     \/_/
--
-- https://joshbassett.info
-- https://twitter.com/nullobject
-- https://github.com/nullobject
--
-- Copyright (c) 2020 Josh Bassett
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

entity top is
  port (
    -- 50MHz clock
    clk : in std_logic;

    -- buttons
    key : in std_logic_vector(0 downto 0);

    -- LEDs
    led : out std_logic_vector(7 downto 0);

    -- SDRAM interface
    sdram_a     : out unsigned(12 downto 0);
    sdram_ba    : out unsigned(1 downto 0);
    sdram_dq    : inout std_logic_vector(15 downto 0);
    sdram_clk   : out std_logic;
    sdram_cke   : out std_logic;
    sdram_cs_n  : out std_logic;
    sdram_ras_n : out std_logic;
    sdram_cas_n : out std_logic;
    sdram_we_n  : out std_logic;
    sdram_dqml  : out std_logic;
    sdram_dqmh  : out std_logic
  );
end top;

architecture arch of top is
  constant SDRAM_ADDR_WIDTH : natural := 23;
  constant SDRAM_DATA_WIDTH : natural := 32;

  constant ROM_SIZE : natural := 256;

  type state_t is (INIT, LOAD, IDLE);

  signal reset : std_logic;

  -- clock enable
  signal cen : std_logic;

  -- state signals
  signal state, next_state : state_t;

  -- counters
  signal data_counter : natural range 0 to ROM_SIZE-1;

  -- SDRAM signals
  signal sdram_addr  : unsigned(SDRAM_ADDR_WIDTH-1 downto 0);
  signal sdram_din   : std_logic_vector(SDRAM_DATA_WIDTH-1 downto 0);
  signal sdram_we    : std_logic;
  signal sdram_req   : std_logic;
  signal sdram_ack   : std_logic;
  signal sdram_valid : std_logic;
  signal sdram_dout  : std_logic_vector(SDRAM_DATA_WIDTH-1 downto 0);
begin
  -- generate a 1MHz clock enable signal
  clock_divider_50 : entity work.clock_divider
  generic map (DIVISOR => 500000)
  port map (clk => clk, cen => cen);

  -- SDRAM controller
  sdram : entity work.sdram
  generic map (CLK_FREQ => 50.0)
  port map (
    reset => reset,
    clk   => clk,

    -- IO interface
    addr  => sdram_addr,
    data  => sdram_din,
    we    => sdram_we,
    req   => sdram_req,
    ack   => sdram_ack,
    valid => sdram_valid,
    q     => sdram_dout,

    -- SDRAM interface
    sdram_a     => sdram_a,
    sdram_ba    => sdram_ba,
    sdram_dq    => sdram_dq,
    sdram_cke   => sdram_cke,
    sdram_cs_n  => sdram_cs_n,
    sdram_ras_n => sdram_ras_n,
    sdram_cas_n => sdram_cas_n,
    sdram_we_n  => sdram_we_n,
    sdram_dqml  => sdram_dqml,
    sdram_dqmh  => sdram_dqmh
  );

  -- state machine
  fsm : process (state, data_counter)
  begin
    next_state <= state;

    case state is
      when INIT =>
        if data_counter = ROM_SIZE-1 then
          next_state <= LOAD;
        end if;

      when LOAD =>
        if data_counter = ROM_SIZE-1 then
          next_state <= IDLE;
        end if;

      when IDLE =>
        -- do nothing
    end case;
  end process;

  -- latch the next state
  latch_next_state : process (clk, reset)
  begin
    if reset = '1' then
      state <= INIT;
    elsif rising_edge(clk) then
      if cen = '1' then
        state <= next_state;
      end if;
    end if;
  end process;

  update_data_counter : process (clk, reset)
  begin
    if reset = '1' then
      data_counter <= 0;
    elsif rising_edge(clk) then
      if cen = '1' then
        if state /= next_state then -- state changing
          data_counter <= 0;
        else
          data_counter <= data_counter + 1;
        end if;
      end if;
    end if;
  end process;

  reset <= not key(0);

  -- set SDRAM signals
  sdram_clk  <= clk;
  sdram_addr <= to_unsigned(data_counter, sdram_addr'length);
  sdram_din  <= std_logic_vector(to_unsigned(data_counter, sdram_din'length));
  sdram_we   <= '1' when state = LOAD else '0';
  sdram_req  <= '1' when state = LOAD or state = IDLE else '0';

  -- set LED data
  led <= sdram_dout(7 downto 0);
end architecture arch;
