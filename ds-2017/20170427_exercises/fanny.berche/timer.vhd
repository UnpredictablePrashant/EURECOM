library IEEE;
use IEEE.std_logic_1164.all;

entity timer is
    generic(
    freq : positive range 1 to 1000;
    timeout : positive range 1 to 1000000
);

port(
        clk : in std_ulogic;
        sresetn : in std_ulogic;
        pulse : out std_ulogic
);

end timer; 

architecture arc of timer is
    signal counter1 : natural range 0 to freq - 1 := freq - 1;
    signal counter2 : natural range 0 to timeout - 1 := timeout - 1;
    signal tick : std_ulogic;
begin


    counter1_process : process(clk)
    begin
        if clk'event and clk='1' then
            tick <= '0';
            if sresetn = '0' then
                counter1 <= freq - 1;
            elsif counter1 = 0 then
                counter1 <= freq - 1;
                tick <= '1';
            else
                counter1 <= counter1 - 1;
            end if;
        end if;
    end process;


    counter2_process : process(clk)
    begin
        if clk'event and clk='1' then
            pulse <= '0';
            if sresetn = '0' then
                counter2 <= timeout - 1;
            elsif tick = '1' then
                if counter2 = 0 then
                    counter2 <= timeout - 1;
                    pulse <= '1';
                else
                    counter2 <= counter2 - 1;
                end if;
            end if;
        end if;
    end process;

end arc;
