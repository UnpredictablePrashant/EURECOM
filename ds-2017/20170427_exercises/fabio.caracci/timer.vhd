LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
--use ieee.numeric_std.all;

ENTITY timer IS
	generic (freq: positive range 1 to 1000;
		timeout: positive range 1 to 1000000);
	PORT (clk: IN std_ulogic;
		sresetn: IN std_ulogic;
 	      pulse: OUT std_ulogic);
END timer;

ARCHITECTURE arc OF timer IS
signal cnt1: natural range 0 to freq - 1;
signal cnt2: natural range 0 to timeout - 1;
signal tick: std_ulogic;
BEGIN
cnt_1: process(clk)
begin
	if (clk='1' and clk'event) then
		tick <= '0';
		if sresetn = '0' then
			cnt1 <= freq-1;
		elsif cnt1 = 0 then
			cnt1 <= freq-1;
			tick <= '1';
		else
			cnt1 <= cnt1 - 1;
		end if;
	end if;
end process cnt_1;

cnt_2: process(clk)
begin
	if (clk='1' and clk'event) then
		pulse <= '0';
		if sresetn = '0' then
			cnt2 <= timeout - 1;
		elsif tick = '1' then
			if cnt2 = 0 then
				cnt2 <= timeout - 1;
				pulse <= '1';
			else
				cnt2 <= cnt2 - 1;
			end if;
		end if;
	end if;
end process;
	
END arc;