library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity timer is
generic(
    freq:	positive range 1 to 1000;
    timeout:	positive range 1 to 1000000;
);
  port(
    clk:	in	std_ulogic;
    sresetn:	in	std_ulogic;
    pulse:	out	std_ulogic
);
end entity timer;

architecture arc of timer is
begin
    p1: process(clk)
    counter_1 : unsigned(freq-1 downto 0);
    counter_2 : unsigned(timeout-1 downto 0);
    signal tick: std_ulogic;
    begin
	counter_1 := counter_1 - 1;
	if (counter_1 = 0) then
	    counter_1 := freq -1;
	    tick <= 1;
	end if;
	if clk'event and (clk = '1') then
	    if (tick = '1') then
		counter_2 := counter_2 - 1;
		if (counter_2 = 0) then
		    counter_2 := timeout-1;
		    pulse <= 1;
		end if;
	    end if;
	end if;

	if (sresetn = '0') then
	    counter_1 := freq-1;
	    counter_2 := timeout-1;
	end if;
    end process p1;
end architecture arc;
