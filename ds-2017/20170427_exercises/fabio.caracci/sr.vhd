LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
--use ieee.numeric_std.all;

ENTITY sr IS
	PORT (clk: IN std_ulogic;
		sresetn: IN std_ulogic;
		shift: IN std_ulogic;
		di: IN std_ulogic;
 	      do: OUT std_ulogic_vector(3 downto 0));
END sr;

ARCHITECTURE arc OF sr IS
signal reg : std_ulogic_vector(3 downto 0);
BEGIN
do <= reg;
process(clk)
begin
	if (clk='1' and clk'event) then
		if sresetn = '0' then
			reg <= (others => '0');
		elsif shift = '1' then
			reg <= di & reg (3 downto 1);
		end if;
	end if;
end process;
END arc;
