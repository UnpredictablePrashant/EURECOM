library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port ( 
	clk : in  std_ulogic;
	data_in : in  std_ulogic;
	sresetn: in std_ulogic;
	dsensor : out std_ulogic
	);
end edge_detector;

architecture arc of edge_detector is
	signal stabilizer: std_ulogic_vector(2 downto 0); 
begin

	generator_binary: process(clk)
	begin
		if(rising_edge(clk)) then
			if sresetn='0' then
				stabilizer <= (others=>'0');
			else
				stabilizer <= data_in & stabilizer (2 downto 1);
			end if;
		end if;
	end process generator_binary;
	dsensor <= stabilizer(1) xor stabilizer(0);
		
end arc;
