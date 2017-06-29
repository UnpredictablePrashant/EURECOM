-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

-- Simulation environments are frequently back boxes
entity ct_sim is
end entity ct_sim;

architecture sim of ct_sim is

	signal sw0: std_ulogic;
	signal wi:  std_ulogic;
	signal wo:  std_ulogic;
	signal led: std_ulogic_vector(3 downto 0);

begin

  -- entity instantiation of the Design Under Test
	dut: entity work.ct(arc)
		port map(
			switch0  => sw0,
			wire_in  => wi,
			wire_out => wo,
			led      => led
		);

  -- signals can be assigned waveforms, let's use this to generate 4 possible combinations of the 2 inputs
	sw0 <= '0', '1' after 10 ns, '0' after 20 ns, '1' after 30 ns, '0' after 40 ns;
	wi  <= '0',                  '1' after 20 ns,                  '0' after 40 ns;

end architecture sim;
