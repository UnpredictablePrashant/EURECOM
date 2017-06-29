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
	signal cnt: integer := freq-1;
	signal cnt2: integer := timeout-1;
	signal tick: std_ulogic;
	BEGIN 
	
	process (clk)
    	begin
	    if (clk' event and clk='1') then
		if(sresetn='1' or cnt=0) then 
			cnt<=freq-1;
			tick<='1';
		else
			cnt<=cnt-1;
		end if;
	    end if;

	end process;

	process (clk)
    	begin
	    if (clk' event and clk='1') then
		if(sresetn='1' or cnt2=0) then 
			cnt2<=timeout-1;
			pulse<='1';
		else
			cnt2<=cnt2-1;
		end if;
	    end if;

	end process;
END arc;

