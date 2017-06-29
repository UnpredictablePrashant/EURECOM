library IEEE;
use IEEE.std_logic_1164.all;

entity sr is 
	port(
		clk: in std_ulogic;
		sresetn: in std_ulogic;
		shift: in std_ulogic;
		di: in std_ulogic;
		do: out std_ulogic_vector(3 downto 0)
	);
end entity sr;

architecture arc of sr is
	signal reg: std_ulogic_vector(3 downto 0);
begin
	P1: process(clk)
	begin
		if(rising_edge(clk)) then
			if(sresetn = '0') then
				reg <= (others => '0'); -- same as "0000"
			elsif (shift = '1') then
				reg <= di & reg(3 downto 1) ; -- concatenate di eg '1' + three left from reg eg '101' that is in total 4
			end if;
		end if;	
	end process P1;
	
	do <= reg;
	
	-- Vhdl protection prevents to create two processes sending sign to the same signal it is shozed  with unresolved type reg
	--shiftprocess: process(clk)	
	--begin
	--	if(rising_edge(clk)) then
	--		reg <= reg srl 1;
	--	end if;	
	--end process shiftprocess;
	
		
end architecture arc;
	

