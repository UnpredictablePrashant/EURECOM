library ieee;
use ieee.std_logic_1164.all;
entity sm is
port(
	clk: in std_ulogic;
	sresetn: in std_ulogic;
	go:in std_ulogic;
	stp:in std_ulogic;
	spin:in std_ulogic;
	up:out std_ulogic);	
end sm;
architecture arc of sm is
	type state_type is (IDLE,RUN,HALT);
	signal state: state_type;
BEGIN 	
	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn='0' then
				state<=IDLE;
			else 
				case state is
					when IDLE=>
						if go='0' then
							state<= IDLE;
						else
							state<= RUN;
						end if;
					when RUN=>
						if stp='0' then
							state<=RUN;
						else 
							state<=HALT;
						end if;
					when HALT=>
						if spin='1' then
							state<=HALT;
						elsif go='1' then
							state<=RUN;
						else
							state<=IDLE;
						end if;
				end case;
			end if;
		end if;
	end process;
	process(state)
	begin
		case state is
			when IDLE=>up<='0';
			when RUN=>up<='1';
			when HALT=>up<='0';
		end case;
	end process;
end arc;


	
