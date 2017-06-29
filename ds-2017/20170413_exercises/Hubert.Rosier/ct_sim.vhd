library ieee;
use ieee.std_logic_1164.all;

entity ct_sim is
  end entity ct_sim;

architecture sim of ct_sim is
  signal switch0:  std_ulogic;
  signal wire_in: std_ulogic;
  signal wire_out:  std_ulogic;
  signal led:  std_ulogic_vector(3 downto 0);

begin
  u0: entity work.ct(arc)
  port map(
            switch0 => switch0,
            wire_in => wire_in,
            wire_out => wire_out,
            led => led
          );
  process
  begin
    wire_in <= '1';
    switch0 <= '1';
    wait for 5 us;
    wire_in <= '0';
    switch0 <= '1';
    wait for 5 us;
    wire_in <= '0';
    switch0 <= '0';
    wait for 5 us;
    wire_in <= '1';
    switch0 <= '0';
    wait for 5 us;
    wait; -- Eternal wait. Stops the process forever.
  end process;

end architecture sim;
