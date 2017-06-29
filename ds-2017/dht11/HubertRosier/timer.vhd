library IEEE;
use IEEE.std_logic_1164.all;

entity timer is
    generic(
    freq : positive range 1 to 1000
);

port(
        clk : in std_ulogic;
        sresetn : in std_ulogic;
        pulse : out std_ulogic
);

end timer; 

architecture arc of timer is
    signal counter1 : natural range 0 to freq - 1 := freq - 1;
begin

    counter1_process : process(clk)
    begin
        if rising_edge(clk) then
            pulse <= '0';
            if sresetn = '0' then
                counter1 <= 0;
            elsif counter1 = 0 then
                counter1 <= freq - 1;
                pulse <= '1';
            else
                counter1 <= counter1 - 1;
            end if;
        end if;
    end process;
end arc;
