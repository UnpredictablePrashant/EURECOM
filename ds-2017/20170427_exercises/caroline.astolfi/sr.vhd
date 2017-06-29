library ieee;
use ieee.std_logic_1164.all;


entity sr is
	port (         
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
	do <= reg;

	process (clk)
	begin 	
		if rising_edge(clk) then
			if sresetn='0' then
				reg(3) <= '0';
				reg(2) <= '0';
				reg(1) <= '0';
				reg(0) <= '0';
			elsif shift='1' then
				reg(3) <= di;
				reg(2) <= reg(3);
				reg(1) <= reg(2);
				reg(0) <= reg(1);
			end if;
		end if;
	end process;

end architecture arc;
