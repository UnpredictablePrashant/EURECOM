library ieee; 
use ieee.std_logic_1164.all; 

entity sm is 	
	port (         		
		clk: in std_ulogic;         		
		sresetn: in std_ulogic;         		
		go: in std_ulogic; 			
		stp: in std_ulogic; 		
		spin: in std_ulogic;
		up: out std_ulogic    	
	); 
end entity sm;

architecture arc of sm is
	type ST is (IDLE, RUN, HALT) ;
	
	signal state, next_state : ST;

begin
	P1 : process (clk, sresetn)
	begin 
		if rising_edge(clk) then
			if sresetn='0' then
				state <= IDLE ;
			else 
				state <= next_state;
			end if;
		end if;
	end process P1;
	
	P2 : process (state)
	begin
		if (state = IDLE or state = HALT) then
			up <= '0';
		elsif (state = RUN) then
			up <= '1';
		end if;
	end process P2;

	P3 : process (state, go, stp, spin)
	begin
		case state is
			when IDLE => 
				if (go = '0') then 
					next_state <= state;
				else
					next_state <= RUN;
				end if;
			when RUN => 
				if (stp = '0') then 
					next_state <= state;
				else
					next_state <= HALT;
				end if;
			when HALT => 
				if (spin = '1') then 
					next_state <= state;
				else
					if (go = '1') then
						next_state <= RUN;
					else 
						next_state <= IDLE;
					end if;
				end if;
		end case;
	end process P3;

end architecture arc;
