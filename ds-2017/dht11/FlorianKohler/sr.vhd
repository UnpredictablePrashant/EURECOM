library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sr is
	port(
	    	clk:      in  std_ulogic;
	   	srstn:  in  std_ulogic;
	    	shift:    in  std_ulogic;
	    	do_bit:       in  std_ulogic;
	   	do:       out std_ulogic_vector(39 downto 0);
		shiftregister_reset : in std_ulogic

	);
end entity sr;

architecture arc of sr is
	signal reg: std_ulogic_vector(39 downto 0);
begin
	do <=reg;

	shiftregister:process(clk,shiftregister_reset)
	begin
		if clk'event and clk = '1' then
			if (srstn = '0' or shiftregister_reset = '1') then -- synchronous, active low, reset
				reg <= (others => '0'); -- aggregate notation
			elsif shift = '1' then
				reg <= reg(38 downto 0) & do_bit ; -- use concatenation and bit-slicing
			end if;			
		end if;
	end process shiftregister;
end architecture arc;
