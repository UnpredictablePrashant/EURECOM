library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity timer is
    generic(
        freq:	positive range 1 to 1000;
        timeout:	positive range 1 to 1000000
    );
    port(
        clk:	    in	std_ulogic;
        sresetn:    in	std_ulogic;
        pulse:	    out	std_ulogic
    );
end entity timer;

architecture arc of timer is
    	signal cnt_1: natural range 0 to freq - 1;
    	signal cnt_2: natural range 0 to timeout - 1;
    	signal tick: std_ulogic;
begin
    process(clk)
    begin
        -- Uses clk as its master clock.
        if clk'event and (clk = '1') then
	    tick <= '0';
            -- active low reset to force the two counters to their reset values
            if (sresetn = '0') then
        	cnt_1 <= freq - 1;
            else
    		--  first counter
	        if (cnt_1 = 0) then
	            cnt_1 <= freq -1;
	            tick <= '1';
	        else
		    cnt_1 <= cnt_1 - 1;
		end if;
	    end if;
	end if;
    end process;

    process(clk)
    begin
        -- Uses clk as its master clock.
        if clk'event and (clk = '1') then
	    pulse <= '0';
            -- active low reset to force the two counters to their reset values
            if (sresetn = '0') then
        	cnt_2 <= timeout - 1;
            else
		-- second counter
		if (tick = '1') then
	 	  	if (cnt_2 = 0) then
	 	  	    cnt_2 <= timeout-1;
	 	  	    pulse <= '1';
			else
			   cnt_2 <= cnt_2 - 1;
			end if;
 	  	end if;
	    end if;
	end if;
    end process;
end architecture arc;
