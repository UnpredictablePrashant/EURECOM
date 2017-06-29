library IEEE;
--use ieee.numeric_std.all;
use IEEE.std_logic_1164.all;

entity sr is 
    port(
        clk: in std_ulogic;
        sresetn: in std_ulogic;
        shift: in std_ulogic;
        di: in std_ulogic;
        do: out std_ulogic_vector(3 downto 0)
    );
end entity sr;

architecture arc of sr is

    signal reg:   std_ulogic_vector(3 downto 0);
    begin
	do <= reg;
        P1: process (clk)
        begin
            if (clk'event and clk = '1' and shift = '1' and sresetn = '1') then
                reg(2 downto 0) <= reg(3 downto 1);
                reg(3) <= di;
            end if;
            
            if (clk'event and clk = '1' and  sresetn = '0') then
                --reg(3) <= '0';
                --reg(2) <= '0';
                --reg(1) <= '0';
                --reg(0) <= '0';
                reg <= (others => '0');
            end if;

        end process P1;
end architecture arc;
