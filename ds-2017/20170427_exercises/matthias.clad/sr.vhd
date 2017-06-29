library IEEE;
use IEEE.std_logic_1164.all;

entity sr is
    port(
    	clk	:	in 	std_ulogic;
        sresetn	:    	in   	std_ulogic;
        shift	:    	in   	std_ulogic;
	di	:	in 	std_ulogic;
        do	:    	out   	std_ulogic_vector(3 downto 0)
    );
end entity sr;

architecture arc of sr is
	signal reg: std_ulogic_vector(3 downto 0);
begin
    
    process(clk)
    begin
        if clk'event and clk='1' then
            if sresetn='0' then
	        reg<=(others=>'0');
            elsif shift='1' then
                reg(3)<=di;
                reg(2)<=reg(3);
                reg(1)<=reg(2);
                reg(0)<=reg(1);
            end if;
         end if;
    end process;

    do<=reg;

end architecture arc;
