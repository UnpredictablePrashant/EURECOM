library IEEE;
use IEEE.std_logic_1164.all;

entity timer is
	generic(
	freq: positive range 1 to 1000;
	timeout: positive range 1 to 1000000
	);
    port(
    	clk:	in std_ulogic;
        sresetn:    in   std_ulogic;
        pulse:        out   std_ulogic
    );
end timer;

architecture arc of timer is
	signal tick: std_ulogic;
	signal counter_1: natural range 0 to freq-1;
	signal counter_2: natural range 0 to timeout-1;


begin
	counter1: process(clk)
		begin
			if clk'event and clk='1' then
				tick <= '0';
				if sresetn='0' then
					counter_1 <= freq-1;
				elsif counter_1=0 then
					counter_1 <= freq -1;
					tick <= '1';
				else
					counter_1 <= counter_1 -1;					
				end if;
			
			end if;
		end process counter1;
	counter2: process(clk)
		begin
			if clk'event and clk='1' then
				pulse<='0';
				if sresetn='0' then
					counter_2 <= timeout-1;
				elsif counter_2=0 and tick='1' then
					counter_2 <= timeout -1;
					pulse <= '1';
				elsif tick='1' then
					counter_2 <= counter_2 -1;
				end if;
			end if;
		end process counter2;
end architecture arc;

