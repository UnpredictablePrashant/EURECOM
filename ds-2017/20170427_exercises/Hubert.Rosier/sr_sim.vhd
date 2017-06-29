library ieee;
use ieee.std_logic_1164.all;

entity sr_sim is
  end entity sr_sim;

architecture sim of sr_sim is
  signal clk:  std_ulogic;
  signal sresetn: std_ulogic;
  signal shift:  std_ulogic;
  signal di:  std_ulogic;
  signal do:  std_ulogic_vector(3 downto 0);

begin
  u0: entity work.sr(arc)
  port map(
            clk => clk,
            sresetn => sresetn,
            shift => shift,
            di => di,
            do => do
          );

  CLK_GEN : process
  begin
    CLK <= '0';
    wait for 5 us;
    CLK <= '1';
    wait for 5 us;
  end process;

  process
  begin
    di <= '1';
    wait for 5 us;
    shift <= '1';
    sresetn <= '0';
    di <= '0';
    wait for 10 us;
    di <= '1';
    wait for 30 us;
    di <= '0';
    wait for 10 us;
    shift <= '0';
    di <= '1';
    wait for 20 us;
    sresetn <= '1';
    wait for 10 us;
    shift <= '1';
    wait; -- Eternal wait. Stops the process forever.
  end process;

end architecture sim;
