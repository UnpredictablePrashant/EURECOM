library ieee; 
use ieee.std_logic_1164.all; 

entity timer is     
	generic (
		freq : positive range 1 to 1000;
		timeout: positive range 1 to 10000000
	);
	port (
		clk: in std_ulogic ;
		sresetn: in std_ulogic ;
		pulse: out std_ulogic
	); 
end entity timer;

architecture arc of timer is 
	signal tick: std_ulogic;
	signal FC: natural range 0 to freq - 1;
	signal SC: natural range 0 to timeout - 1;
begin     
	process (clk) -- First counter
	begin
		if rising_edge(clk) then 
			tick <='0';
			if sresetn = '0' then
				FC <= freq - 1;
			elsif FC = 0 then
				FC <= freq - 1;
				tick <= '1';
			else
				FC <= FC - 1;
			end if;
		end if;
	end process;

	process (clk) -- Second counter
	begin
		if rising_edge(clk) then 
			pulse <='0';
			if sresetn = '0' then
				SC <= timeout - 1;
			elsif tick ='1' then
				if SC = 0 then
					SC <= timeout - 1;
					pulse <= '1';
				else
					SC <= SC - 1;
				end if;
			end if;
		end if;
	end process;

end architecture arc;


