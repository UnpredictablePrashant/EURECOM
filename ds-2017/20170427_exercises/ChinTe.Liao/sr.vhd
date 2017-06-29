library ieee;
use ieee.std_logic_1164.all;

entity sr is
  port(
    clk  : in  std_ulogic;
    sresetn: in  std_ulogic;
    shift:    in std_ulogic;     
    di:     out  std_ulogic;
    do:     out  std_ulogic_vector(3 downto 0)
);
end entity sr;

architecture arc of sr is
 signal reg: std_ulogic_vector(3 downto 0);

begin


 p2: process(reg)
  begin
     do <= reg;
  end process p2;

 p3: process(clk)
  begin
   if clk='1' and clk'event then
     if sresetn='1'and shift='1' then
--    reg(0)<=reg(1);
--    reg(1)<=reg(2);
--    reg(2)<=reg(3);
--    reg(3)<=di;
      reg <= di & reg(3 downto 1);
     elsif sresetn='0'then
        reg <= "0000";
     end if;
   end if;
  end process p3;

end architecture arc;






