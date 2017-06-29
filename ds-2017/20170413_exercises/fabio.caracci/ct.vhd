LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY ct IS
	PORT (switch0: IN std_ulogic;
		wire_in: IN std_ulogic;
 	      wire_out: OUT std_ulogic;
 	      led: OUT std_ulogic_vector(3 downto 0));
END ct;

ARCHITECTURE arc OF ct IS
BEGIN
	wire_out <= switch0;
	led(0) <= '1';
	led(1) <= '0';
	led(2) <= wire_in;
	led(3) <= not wire_in;
END arc;
