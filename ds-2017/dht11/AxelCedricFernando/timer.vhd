library IEEE;
use IEEE.std_logic_1164.all;

entity timer is 
	generic(
		freq: positive range 1 to 1000
	);
	port(
		timeout: in positive range 1 to 1500000;
		fsm_reset: in std_ulogic;
		clk: in std_ulogic;
		sresetn: in std_ulogic;
		pulse: out std_ulogic
	);
end entity timer;

architecture arc of timer is
	signal tick: std_ulogic;
	signal counter1: natural range 0 to freq - 1;
	signal counter2: natural;
begin
	counter: process(clk)
	begin
		if(rising_edge(clk)) then
			tick <= '0'; -- if it's changed below it won't be 0
			if(sresetn = '0' or fsm_reset = '1') then
				counter1 <= (freq-1);
			elsif (counter1 = 0) then
				counter1 <= freq-1;
				tick <= '1';
			else
				counter1 <= counter1-1;
			end if;
		end if;		
	end process counter;

	counterbis: process(clk)
	begin
		if rising_edge(clk) then	
			if(sresetn = '0' or fsm_reset = '1') then
				counter2 <= timeout-1;
				pulse <= '0'; -- to renitialize cnt and pulse
			elsif (counter2 = 0) then
			    pulse <= '1';
			else 
				counter2 <= counter2-1;
			end if;
		end if;		
	end process counterbis;
		
end architecture arc;
	

