LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY sm IS
	PORT (clk: IN std_ulogic;
		sresetn, go, stp, spin: IN std_ulogic;
		up: OUT std_ulogic);
END sm;

ARCHITECTURE arc OF sm IS
type codeop is (IDLE, RUN, HALT);
signal state: codeop;

BEGIN
P1: process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				state <= IDLE;
			else
			case (state) is
				when IDLE => if (go ='0') then state <= IDLE;
						elsif (go ='1') then state <= RUN;
						end if;
				when RUN => if (stp ='0') then state <= RUN;
						elsif (stp ='1') then state <= HALT;
						end if;
				when HALT => if (spin ='1') then state <= HALT;
						elsif (go ='1' and spin ='0') then state <= RUN;
						elsif (go ='0' and spin ='0') then state <= IDLE;
						end if;
				when others => state <= IDLE;
			end case;
			end if;
		end if;
	end process P1;

P2: process(state)
	begin
		up <= '0';
		case (state) is
			when IDLE 	=> up <= '0';
			when RUN 	=> up <= '1';
			when HALT 	=> up <= '0';
		end case;
	end process P2;
end arc;

