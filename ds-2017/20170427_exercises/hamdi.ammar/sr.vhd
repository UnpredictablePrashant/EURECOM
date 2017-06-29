library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sr is
  port(
    clk:   in  std_ulogic;
    sresetn:   in  std_ulogic;
    shift:   in  std_ulogic;
    di:   in  std_ulogic;
    do:   out  std_ulogic_vector(3 downto 0)
 
  );
end entity sr;

architecture arc of sr is
signal reg:  std_ulogic_vector(3 downto 0);
begin
p1: process(clk)

begin

if (rising_edge(clk)) then
	
	if(sresetn= '0') then
  reg<= "0000";
	else
reg<=di & reg(3 downto 1);
	end if;
do <= reg;
end if;


end process p1;
end architecture arc;

