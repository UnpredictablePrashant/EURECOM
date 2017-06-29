use std.textio.all;
use std.env.all;
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.math_real.all;


entity arc_tb is
end arc_tb;


ARCHITECTURE BHV OF arc_tb IS
  SIGNAL sw0, wi, wo: std_ulogic;
  SIGNAL led: std_ulogic_vector(3 downto 0);
BEGIN


dut: entity work.ct(arc)
	port map(
		switch0  => sw0, 
		wire_in  => wi, 
		wire_out => wo,
		led      => led
);
	
Inputs: PROCESS
BEGIN
  sw0 <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
  
  wi <=  '0', '1' after 20 ns, '0' after 40 ns;
	wait;
END PROCESS;


END BHV;

