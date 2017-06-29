-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sm is
	port(
	    clk:      in  std_ulogic;
	    sresetn:  in  std_ulogic;
	    go:       in  std_ulogic;
	    stp:      in  std_ulogic;
	    spin:     in  std_ulogic;
	    up:       out std_ulogic
	);
end entity sm;

architecture arc of sm is
	type states is (idle, run, halt);
	signal state, next_state: states;
begin
	up <= '1' when state = run else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then -- synchronous, active low, reset
				state <= idle;
			else
				state <= next_state;
			end if;
		end if;
	end process;

	process(state, go, stp, spin)
	begin
		next_state <= state; -- by default, stay in same state
		case state is
			when idle =>
				if go = '1' then
					next_state <= run;
				end if;
			when run =>
				if stp = '1' then
					next_state <= halt;
				end if;
			when halt =>
				if spin = '0' then
					if go = '1' then
						next_state <= run;
					else
						next_state <= idle;
					end if;
				end if;
		end case;
	end process;
end architecture arc;
