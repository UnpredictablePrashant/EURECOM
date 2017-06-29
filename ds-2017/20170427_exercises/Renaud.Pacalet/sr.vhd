-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sr is
	port(
	    clk:      in  std_ulogic;
	    sresetn:  in  std_ulogic;
	    shift:    in  std_ulogic;
	    di:       in  std_ulogic;
	    do:       out std_ulogic_vector(3 downto 0)
	);
end entity sr;

architecture arc of sr is
	signal reg: std_ulogic_vector(3 downto 0);
begin
	do <= reg;

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then -- synchronous, active low, reset
				reg <= (others => '0'); -- aggregate notation
			elsif shift = '1'  then
				reg <= di & reg(3 downto 1); -- use concatenation and bit-slicing
			end if;
		end if;
	end process;
end architecture arc;
