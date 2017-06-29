library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sr is
port (
 clk, sresetn, shift, di : in std_ulogic;
 do : out std_ulogic_vector(3 downto 0));
end entity sr;

architecture arc of sr is
signal reg : std_ulogic_vector(3 downto 0);
begin
 do <= reg;
 p1 : process(clk)
 begin
  if rising_edge(clk) then
   if(sresetn = '0') then
    reg(3) <= '0';
    reg(2) <= '0';
    reg(1) <= '0';
    reg(0) <= '0';
    --can also do reg <= (others => '0');
   elsif(shift= '1') then
    reg <= di & reg(3 downto 1);
   end if;
  end if;
 end process p1;
end architecture arc;
