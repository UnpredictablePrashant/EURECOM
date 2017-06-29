library ieee;
use ieee.std_logic_1164.all;

entity timer is
    generic(
	freq	: 	positive range 1 to 1000;
	timeout	: 	positive range 1 to 1000000);
    port(
	clk     : 	in  std_ulogic;
	sresetn : 	in  std_ulogic;
	pulse   : 	out std_ulogic
    );
end entity timer;

architecture arc of timer is

signal 	first 	: 	positive range 0 to freq-1;
signal 	second	: 	positive range 0 to timeout-1;
signal 	tick  	: 	std_ulogic;

begin

    process(clk)
    begin
        if clk'event and clk='1' then
            if sresetn='0' then
	        first<=freq-1;
                tick<='0';
            else
                if first=0 then
                    first<=freq-1;
                    tick<='1';
                else
                    first<=first-1;
                    tick<='0';
                end if;
            end if;
         end if;
    end process;

    process(clk)
    begin
        if clk'event and clk='1' then
            if sresetn='0' then
                second<=timeout-1;
                pulse<='0';
            elsif tick='1' then
                if second=0 then
                    second<=timeout-1;
                    pulse<='1';
                else
                    second<=second-1;
                    pulse<='0';
                end if;
            else
                pulse<='0';
            end if;
         end if;
    end process;

end architecture arc;
