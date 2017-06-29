--Based on the writeup here: https://www.doulos.com/knowhow/fpga/synchronisation/
library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity syncdata is
                        port(
                                clk:     in  std_ulogic;
                                d_in:    in  std_ulogic;
                                srstn:   in  std_ulogic;
                                rise:    out std_ulogic;
                                fall:    out std_ulogic
                                    );
-- problem: should be data changes, then 3 cs later the rise or fall is asserted
-- instead, data changes then on 2nd cs rise or fall is asserted. 
end entity syncdata;

architecture arc of syncdata is
    signal reg1: std_ulogic;
    signal reg2: std_ulogic;
    signal reg3: std_ulogic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            reg1 <= '0';
            if srstn = '0' then
                reg1 <= '0';
            else
                reg1 <= d_in;
            end if;
        end if;
   end process;

    process(clk)
    begin
        if rising_edge(clk) then
            reg2 <= '0';
            if srstn = '0' then
                reg2 <= '0';
            else
                reg2 <= reg1;
            end if;
        end if;
   end process;
   
    process(clk)
    begin
        if rising_edge(clk) then
            reg3 <= '0';
            if srstn = '0' then
                reg3 <= '0';
            else
                reg3 <= reg2;
            end if;
        end if;
   end process;
   
   process(clk)
   begin
       if rising_edge(clk) then
            if srstn = '0' then 
               rise <= '0';
               fall <= '0';
            elsif reg2 = reg3 then
                rise <= '0';
                fall <= '0';
            elsif reg2 = '1' and reg3 = '0' then
                rise <= '1';
                fall <= '0';
            else
                rise <= '0';
                fall <= '1';
            end if;
        end if;
    end process;
end architecture arc;





