--has to be compiled with vhdl -2008 because the outputs are read 
LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;

entity timer is
	generic (
		freq : positive range 1 to 1000; -- master clk frequency
		timeout : positive range 1 to 1000000 -- number of ms between two output pulses
	);
	port (
		clk : in std_ulogic; --master clock. the design is synchro on rising edge of clk
		sresetn : in std_ulogic; -- sync, active low reset
		pulse : out std_ulogic -- asserted high for one clk clock period every timeout ms
	);
end entity timer;

architecture arc of timer is
	
	signal tick:std_ulogic; --internal sig asserted every time the first counter wraps
	signal first_counter : natural range 0 to freq -1; --wraps around 0 and restart @ freq-1
	signal second_counter : natural range 0 to timeout - 1; --wraps around 0 and restart @ timeout-1 

begin
	process (clk)
	begin
		if rising_edge(clk) then
			tick <= '0';
			if sresetn = '0' then -- reset value @ freq -1
				first_counter <= freq-1; 
			elsif first_counter = 0 then -- wraps around 0
				first_counter <=freq-1;
				tick<='1';
			else -- decrement at clk frequency
				first_counter <= first_counter -1 ; 
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) then
			pulse <= '0';
			if sresetn = '0' then -- reset value @ timeout -1
				second_counter <= timeout-1; 
			elsif tick = '1' then -- tick is asserted
				if second_counter = 0 then -- if wraps around 0 then assert pulse
					second_counter <= timeout-1 ;
					pulse <= '1';
				else --else decrement
					second_counter <= second_counter -1 ;
				end if;
			end if;
		end if;
		
	end process;

end architecture arc;

