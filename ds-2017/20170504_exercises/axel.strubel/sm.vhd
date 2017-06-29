library IEEE;
use IEEE.std_logic_1164.all;

entity sm is 
	port(
		clk: in std_ulogic;
		sresetn: in std_ulogic;
		go: in std_ulogic;
		stp: in std_ulogic;
		spin: in std_ulogic;
		up: out std_ulogic
	);
end entity sm;

architecture arc of sm is
	type state_type is (IDLE, RUN, HALT);
	signal ps,ns: state_type;	
begin

	up <= '1' when ps = RUN else '0' ;--up is enabled only when state machine is in run mode

	sync_process: process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				ps <= IDLE;
			else
				ps <= ns;
			end if;
		end if;
	end process sync_process;

	comb_process: process(ps,go,stp,spin)
	begin
		-- solution of the teacher to not use each time an else do this ns <= ps; need to be sure that it is assigned no matter what so default value;
		
		case ps is
			when IDLE =>
				if (go = '0') then
					ns <= IDLE;
				else 
					ns <= RUN;
				end if; 
			when RUN =>
				if (stp = '0') then
					ns <= RUN;
				else 
					ns <= HALT;
				end if; 

			when HALT =>
				if (spin = '1') then 
					ns <= HALT;
				elsif (go = '1' and spin ='0') then
					ns <= RUN;
				else
					ns <= IDLE;
				end if;
		end case;
	end process comb_process;
		
end architecture arc;
	

