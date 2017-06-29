library IEEE;
use IEEE.std_logic_1164.all;

entity timer is
	generic(
        freq: positive range 1 to 1000;
        timeout: positive range 1 to 1000000
    );
    port(
    	clk:	in std_ulogic;
        sresetn:   in   std_ulogic;
        pulse:     out   std_ulogic
    );

end timer;

architecture arc of timer is
    signal tick: std_ulogic := '0';
begin

    process(clk)
	    variable firstCounter: natural range 0 to freq - 1;
        variable secondCounter: natural range 0 to timeout - 1;
    begin
        if rising_edge(clk)
        then
            tick <= '0';
            if firstCounter = 0 then
                firstCounter := freq - 1;
                tick <= '1';
            else
                firstCounter := firstCounter - 1;
            end if;


            if tick = '1'
            then
                pulse <= '0';
                if secondCounter = 0 then
                    secondCounter := timeout - 1;
                    pulse <= '1';	
                else
                    secondCounter := secondCounter - 1;
                end if;
            end if;

            if sresetn = '0' then
                firstCounter := freq - 1;
                secondCounter := timeout -1;
            end if;
        end if;

    end process;

end arc;
