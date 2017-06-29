library IEEE;
use IEEE.std_logic_1164.all;

entity sm is
    port(
    	clk:	in std_ulogic;
        sresetn:    in   std_ulogic;
		go: in std_ulogic;
		stp: in std_ulogic;
        spin:    in   std_ulogic;
        up:        out   std_ulogic
    );
end sm;

architecture arc of sm is
	type state_type is (IDLE,RUN,HALT);
	signal state,next_state: state_type;
begin
    
	process (clk, stp,go,spin, sresetn)
	begin
		if rising_edge(clk)
		then
			if sresetn = '0' then
				next_state <= IDLE;
			else
				case state is
					when IDLE => 
						if go = '0' then
							next_state <= IDLE;
						else
							next_state <= RUN;
						end if; 

					when RUN => 
						if stp = '0' then
							next_state <= RUN;
						else
							next_state <= HALT;
						end if;

					when HALT => 
						if spin = '1' then
							next_state <= HALT;
						elsif go = '1' then
							next_state <= RUN;
						else
							next_state <= IDLE;
						end if;
					when others =>
							next_state <= IDLE;
				end case;
			end if;

			
		end if;
	end process;
	
	process (next_state)
	begin
		case next_state is
			when RUN =>
				up <= '1';
			when others =>
				up <= '0';
		end case;
		state <= next_state;
	end process;

end arc;
