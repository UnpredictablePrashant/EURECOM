library ieee;
use ieee.std_logic_1164.all;


entity ct_sim is 
 end entity ct_sim;

architecture sim of ct_sim is
signal test_sw0: std_ulogic; 
signal test_wire_in:  std_ulogic; 
signal test_wire_out:  std_ulogic; 
signal led: std_ulogic_vector(3 downto 0);

begin
wi: process 

begin
test_wire_in<='0';
test_wire_in<= '1' after 20 ns;
test_wire_in<= '0' after 40 ns;
wait;
end process;

sw: process 

begin
test_sw0<='1';
test_sw0<= '0' after 20 ns;
test_sw0<= '1' after 40 ns;
wait;
end process;
dut: entity work.ct(arc)port map(switch0  => test_sw0,wire_in  => test_wire_in,wire_out => test_wire_out, led=> led);
end architecture sim;
