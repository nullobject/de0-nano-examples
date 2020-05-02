library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  port (
    clk : in std_logic;
    led : out std_logic_vector(7 downto 0)
  );
end counter;

architecture arch of counter is
  signal n : natural range 0 to 255;
  signal cen : std_logic;
begin
  clock_divider : entity work.clock_divider
  generic map (DIVISOR => 5000000)
  port map (clk => clk, cen => cen);

  counter : process(clk)
  begin
    if rising_edge(clk) then
      if cen = '1' then
        n <= n + 1;
        led <= std_logic_vector(to_unsigned(n, led'length));
      end if;
    end if;
  end process;
end arch;
