LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


ENTITY timer IS 
	generic (freq: positive range 1 to 1000;
	         timeout: positive range 1 to 1000000);
	PORT (clk: in std_ulogic;
	      sresetn: in std_ulogic; 
	      pulse: out std_ulogic);
END timer;

ARCHITECTURE arc OF timer IS
	signal cnt1: natural range 0 to freq - 1;
	signal cnt2: natural range 0 to timeout - 1;
	signal tick: std_ulogic;
	BEGIN 
	
	process (clk)
    	begin
	    if rising_edge(clk) then
		if sresetn='0'then 
			tick<='0';
			cnt1<=freq-1;
		elsif cnt1=0 then
			cnt1<=freq-1; --wrap around 0
			tick<='1';
		else
			tick<='0';
			cnt1<=cnt1-1;
		end if;
	    end if;

	end process;

	process (clk)
    	begin
	    if rising_edge(clk) then
		if sresetn='0' then
			pulse<='0';
			cnt2<=timeout-1;
		elsif cnt2=0 then
			cnt2<=timeout-1; --wrap around 0
			pulse<='1';
		else
			pulse<='0';
			cnt2<=cnt2-1;
		end if;
	    end if;

	end process;
END arc;

