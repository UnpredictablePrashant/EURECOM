library IEEE;
use IEEE.std_logic_1164.all;

entity sr is
    port(
    	clk:	in std_ulogic;
        sresetn:    in   std_ulogic;
        shift:    in   std_ulogic;
	    di:	in std_ulogic;
        do:        out   std_ulogic_vector(3 downto 0)
    );
end sr;

architecture arc of sr is
	signal reg: std_ulogic_vector(3 downto 0);
begin
    
    do <= reg;

    Shifter: process(shift, clk)
    begin
        if rising_edge(clk) and sresetn = '0'
        then
            reg <= ('0', '0','0','0');
        end if;

        if rising_edge(clk) and shift = '1' and sresetn = '1'
        then
            reg(0) <= reg(1);
            reg(1) <= reg(2);
            reg(2) <= reg(3);
            reg(3) <= di;

        end if;
    end process Shifter;

end arc;