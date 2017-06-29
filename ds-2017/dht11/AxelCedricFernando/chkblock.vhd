library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity chkblock is 
	port(
		dth: in std_ulogic_vector(39 downto 8);
		sr_chk: in std_ulogic_vector(7 downto 0);
		ce: out std_ulogic
	);
end entity chkblock;

architecture arc of chkblock is
begin
	P1: process(dth,sr_chk)
		variable totalth: std_ulogic_vector(7 downto 0); --TODO check that default behavior of overflow addition is not a problem here 
	begin
		totalth := std_ulogic_vector( to_unsigned(to_integer(unsigned(dth(39 downto 32))),8) +  to_unsigned(to_integer(unsigned(dth(31 downto 24))),8) 
				+ to_unsigned(to_integer(unsigned(dth(23 downto 16))),8) + to_unsigned(to_integer(unsigned(dth(15 downto 8))),8));
		if( totalth(7 downto 0) = sr_chk) then
			ce <= '0';
		else
			ce <= '1';
		end if; 			
	end process P1;
end architecture arc;
	

