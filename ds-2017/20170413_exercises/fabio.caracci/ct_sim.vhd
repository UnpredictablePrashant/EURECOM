LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY ct_sym is

end ct_sym;

ARCHITECTURE sim of ct_sym is
	SIGNAL switch0, wire_in, wire_out: std_ulogic;
	SIGNAL led: std_ulogic_vector(3 downto 0));
BEGIN
sig_gen: process
	BEGIN
		switch0 <= '0';
		wire_in <= '0';
		wait for 20 ns;
		switch0 <= '1';
		wire_in <= '1';
		wait;
	END process;

DUT: entity work.ct port map (switch0, wire_in, wire_out, led);

END sim;
