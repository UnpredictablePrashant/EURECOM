library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity timer is
 generic (
  freq : positive range 1 to 1000;
  timeout : positive range 1 to 1000000);
 port (
  clk: in std_ulogic;
  sresetn : in std_ulogic;
  pulse : out std_ulogic);
end entity timer;

architecture arc of timer is
signal tick : std_ulogic;
signal c1 : natural range 0 to freq - 1;
signal c2 : natural range 0 to timeout - 1;
begin

p1 : process(clk)
 begin
  if rising_edge(clk) then
   tick <= '0';
   if(sresetn = '0') then
    c1 <= freq - 1;
   elsif(c1 = 0) then
    c1 <= freq - 1;
    tick <= '1';
   else
    c1 <= c1 - 1;
   end if;
  end if;
end process p1;

p2 : process(clk)
 begin
  if rising_edge(clk) then
   pulse <= '0';
   if(sresetn = '0') then
    c2 <= timeout - 1;
   elsif(tick = '1') then
    if(c2 = 0) then
     c2 <= timeout - 1;
     pulse <= '1';
    else
     c2 <= c2 - 1;
    end if;
   end if;
  end if;
end process p2;

end architecture arc;
