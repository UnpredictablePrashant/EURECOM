--has to be compiled with vhdl -2008 because the outputs are read 

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;


entity sm is --state machine
	PORT(

		clk :in std_ulogic; --master clock
		sresetn:in std_ulogic; --sync active low reset
		go:in std_ulogic; --go command input
		stp: in std_ulogic; -- stop command input
		spin : in std_ulogic; --spin command input
		up: out std_ulogic -- on output
		
);
end entity sm;


architecture arc of sm is
	type state_type is (IDLE,RUN,HALT);
	signal state : state_type;
begin
	process(clk) --sync reset so only the clock in the sensitivity list !
	begin
		if clk'event and clk='1' then --rising edge of the clock
			if sresetn ='0'	then --active LOW reset
				state <= IDLE;
			else
				case state is -- the output should be assigned each time
				when IDLE =>
					if go='0' then
						state <= IDLE;
					else 
						state <=RUN;
					end if;
				when RUN =>
					if stp='0' then
						state <= RUN;
					else
						state <=HALT;
					end if;
				when HALT =>
					if spin='1' then
						state <= HALT;
					else
						 if go='1' then
							state <=RUN;
						else
							state <= IDLE;
						end if;
					end if;
				end case;
				end if;			
			end if;
	end process; 

	process (state)
   	begin
      		case state is
         		when IDLE =>
            		up <= '0';
         		when RUN =>
            		up <= '1';
         		when HALT =>
            		up <= '0';
      		end case;
   end process; --this can be shortened: up <='1' when state = run else '0';
end architecture arc;
