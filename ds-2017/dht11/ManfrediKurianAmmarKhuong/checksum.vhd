library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checksum is 
	port (
		do : in std_ulogic_vector(39 downto 0);
		ce : out std_ulogic);
end entity checksum;

architecture arc of checksum is
begin
 p1 : process(do)
  variable a : unsigned(7 downto 0);
 begin
   a := (others => '0');
   for i in 4 downto 1 loop
    a := a + unsigned(do(7 + 8 * i downto 8 * i));
   end loop;
   if a /= unsigned(do(7 downto 0)) then
    ce <= '1';
   else
    ce <= '0';
   end if;
end process p1;

end architecture arc;
