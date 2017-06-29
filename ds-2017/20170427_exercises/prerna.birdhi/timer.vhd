library IEEE;
use IEEE.std_logic_1164.all;

entity timer is
        generic(
                freq:    positive range 1 to 1000;
                timeout: positive range 1 to 1000000
        );
        port(
                clk :     in std_ulogic;
                sresetn : in std_ulogic;
                pulse :   out std_ulogic
      );
end entity timer;

architecture arc of timer is
     signal cnt1 : natural range 0 to freq - 1;
     signal cnt2 : natural range 0 to timeout - 1;
     signal tick : std_ulogic;
begin
       process(clk)
       begin
               if rising_edge(clk) then
                       tick <= '0';
                       if sresetn = '0' then
                               cnt1 <= freq - 1;
                       elsif cnt1 = 0 then
                               cnt1 <= freq - 1;
                               tick <= '1';
                       else
                               cnt1 <= cnt1 -1;
                       end if;
                end if;
                end process;


                process(clk)
                begin
                        if rising_edge(clk) then
                                pulse <= '0';
                                if sresetn = '0' then
                                        cnt2 <= timeout - 1;
                                elsif tick = '1' then
                                        if cnt2 = 0 then
                                                cnt2 <= timeout - 1;
                                                pulse <= '1';
                                        else
                                                cnt2 <= cnt2 - 1;
                                        end if;
                                 end if;
                         end if;
       end process;
end architecture arc; 
