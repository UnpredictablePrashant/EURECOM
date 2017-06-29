

use std.textio.all;
use std.env.all;
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.math_real.all;


entity ct_sim is
end ct_sim;


ARCHITECTURE BHV OF ct_sim IS
  SIGNAL sw0, w_in, w_out: std_ulogic;
  SIGNAL led: std_ulogic_vector(3 downto 0);
BEGIN
	
Inputs: PROCESS
BEGIN
  sw0 <= '1';
  wait for 20 ns;
  sw0 <= '0'; 
  wait for 20 ns;
  sw0 <= '1';
  wait for 20 ns;
  sw0 <= '0'; 
  wait for 20 ns;

  w_in <= '1';
  wait for 20 ns;
  w_in <= '0'; 
  wait for 20 ns;
  w_in <= '1';
  wait for 20 ns;
  w_in <= '0'; 
  wait for 20 ns;

END PROCESS;

DUT: entity work.ct PORT MAP(switch0 => sw0, wire_in => w_in, wire_out => w_out, led => led);
END BHV;


