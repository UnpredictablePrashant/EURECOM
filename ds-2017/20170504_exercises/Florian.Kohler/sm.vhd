LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sm IS
	PORT (	clk, sresetn, go, stp, spin : IN std_ulogic; 
		up : OUT std_ulogic);
END sm;


ARCHITECTURE arc OF sm Is
	type state_type is (IDLE, RUN, HALT);
	signal State, NextState : state_type;
BEGIN	
	up <= '1' when State = RUN else '0';

	sync_process: PROCESS(clk)
	BEGIN
 		if rising_edge(clk) then
			if sresetn='0' then
				State <= IDLE;
			else
				State <= NextState;
			end if;
		end if;				
	END PROCESS;
	
	comb_process: PROCESS(State, go, stp, spin)
	BEGIN
		NextState <= State;
		case State is
			when IDLE =>
				if  go='0' then NextState <= IDLE;
				else NextState <= RUN;
				end if;
			when RUN =>
				if stp='0' then NextState <= RUN;
				else NextState <= HALT;
				end if;
			when HALT =>
				if spin='0' then
					if go='1' then NextState <= RUN;
					else NextState <= IDLE;
					end if;
				end if;
		end case;
	
	END PROCESS;
END arc;
