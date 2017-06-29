-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sm is
	port(
		clk:      in  std_ulogic;
		sresetn:   in  std_ulogic;
		go:      in  std_ulogic;
		stp:      in  std_ulogic;
		spin:      in  std_ulogic;
		up:      out  std_ulogic
	);
end entity sm;

architecture arc of sm is

	type states is (idle, run, halt);
	signal nxt_state:	states;
	signal state:		states;

begin
	up <= '1' when state = run else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then -- synchronous, active low, reset
				state <= idle;
			else
				state <= nxt_state;
			end if;
		end if;
	end process;

	process(state, go, stp, spin)
	begin
		if state = run then
			if (stp = '0') then
				nxt_state <= run;
			else
				nxt_state <= halt;
			end if;
		else -- state = idle or halt
			if (go = '1') then
				nxt_state <= run;
			else
				nxt_state <= idle;
			end if;
			if (spin = '1') then
				if (state = halt) then
					nxt_state <= halt;
				end if;
			end if;
		end if;
	end process;
end architecture arc;
