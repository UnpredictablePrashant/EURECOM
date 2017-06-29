--has to be compiled with vhdl -2008 because the outputs are read 
LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity sr is --shift register
	PORT(

		clk :in std_ulogic;
		sresetn:in std_ulogic;
		shift:in std_ulogic;
		di: in std_ulogic;
		do : out std_ulogic_vector(3 downto 0)
);
end entity sr;


architecture arc of sr is
	signal reg:std_ulogic_vector(3 downto 0);
begin

	-- register, beware of the delay
	p1:process(clk) -- nothing else than clock in the sensitivity list
	begin
		if rising_edge(clk) then
			if sresetn='0' then --synchronous reset so only the clock matters
				reg <= "0000";
			elsif shift='1' then
				reg <= di & reg(3 downto 1) ; --shift by one to the right  
			end if; 
		end if;	
	end process p1;

	do <= reg;
end architecture arc;
