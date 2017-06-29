-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity timer is
    generic(
        freq:    positive range 1 to 1000 --;
    );
    port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        timer_rst: in std_ulogic;
        count:    out natural
    );
end entity timer;

architecture arc of timer is
    signal local_count: natural; -- range 0 to timeout - 1;
--    signal new_count: natural;
    signal cnt1: natural range 0 to freq - 1;
begin

    process(clk)
    begin
        --local_count <= local_count;
        if rising_edge(clk) then
            --local_count <= 0;
            if sresetn = '0' or timer_rst = '1'  then -- resets
            	local_count <= 0;
                cnt1 <= freq - 1;
            elsif cnt1 = 0 then
                cnt1 <= freq - 1;
                local_count <= local_count + 1;
            else
                cnt1 <= cnt1 - 1;
                local_count <= local_count;
            end if;
        end if;
    end process;

    count <= local_count;
    --process(local_count)
    --begin
      --  new_count <= local_count;
       -- count <= new_count;
    --end process;
end architecture arc;

