library ieee;
use ieee.std_logic_1164.all;

entity ct_sim is
end ct_sim;

architecture beh of ct_sim is

  signal switch0, wire_in, wire_out: std_ulogic;
  signal led: std_ulogic_vector(3 downto 0);

begin

process
  begin
  switch0 <= '0';
  wire_in <= '1';
  wait for 100 ns;
  switch0 <= '1';
  wire_in <= '0';
  wait for 100 ns;
end process;



DUT: entity work.ct PORT MAP(switch0, wire_in, wire_out, led);

end beh;

