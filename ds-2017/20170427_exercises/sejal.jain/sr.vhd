IEEE library;
use IEEE.std_logic_1164.all;
entity shift_reg is;
port(
	clk    : in std_ulogic;
	sresetn: in std_ulogic;
	shift  : in std_ulogic;
	di     : in std_ulogic;
	do     : out std_ulogic_vector(3 downto 0));
end entity shift_reg;
#architecture
architecture arc of shift_reg is
	signal reg : std_ulogic_vector(3 downto 0);
BEGIN
	do<= reg;
	p1: process(clk)
		begin
			if clk then
				if sresetn ='0' then
					reg<=(others=>'0');
				elsif shift = '1' then
					reg <= di & reg(3 downto 1);
				end if;
			end if;
		end process;
end architecture arc;
	
	
