library IEEE;
use IEEE.std_logic_1164.all;

entity sr is
  Port(
             clk:     in std_ulogic;
             sresetn: in std_ulogic;
             shift:   in std_ulogic;
             di:      in std_ulogic;
             do:      out std_ulogic_vector(3 downto 0));
end sr;

architecture arc of sr is
    signal reg: std_ulogic_vector(3 downto 0);
begin

   do <= reg;

   SHIFT_PROCESS: process(clk)
   begin
     if clk'event and clk='1' then
         if sresetn = '0' then
           reg <= "0000";
         elsif shift ='1' then
              reg <= di & reg(3 downto 1);
         end if;
       end if;
     end process;
end arc;

