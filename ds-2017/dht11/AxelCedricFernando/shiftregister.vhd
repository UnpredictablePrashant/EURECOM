library IEEE;
use IEEE.std_logic_1164.all;

entity sr is 
	port(
		clk: in std_ulogic;
		sresetn: in std_ulogic;
		shift: in std_ulogic;
		dsi: in std_ulogic;
		dth: out std_ulogic_vector(39 downto 8);
		do: out std_ulogic_vector (39 downto 0);
		sr_chk: out std_ulogic_vector(7 downto 0)
	);
end entity sr;

architecture arc of sr is
	signal reg: std_ulogic_vector(0 to 39);
begin
	P1: process(clk)
	begin
		if(rising_edge(clk)) then
			if(sresetn = '0') then
				reg <= (others => '0'); -- same as "00...0"
			elsif (shift = '1') then
				reg <= dsi & reg(0 to 38)  ; -- concatenate dsi eg '1' + with everything from reg except the rightmost bit
			end if;
		end if;	
	end process P1;
	
	dth <= reg(8 to 39); --Check that it is indeed put in dth in the right order in dth(39 downto 8) 
	sr_chk <= reg(0 to 7);
	do <= reg(0 to 39);
	-- Vhdl protection prevents to create two processes sending sign to the same signal it is showed  with unresolved type reg
	--shiftprocess: process(clk)	
	--begin
	--	if(rising_edge(clk)) then
	--		reg <= reg srl 1;
	--	end if;	
	--end process shiftprocess;
	
		
end architecture arc;
	

