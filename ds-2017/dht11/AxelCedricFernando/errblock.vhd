library ieee;
use ieee.std_logic_1164.all;

entity errblock is
    port ( 
	ce : in  std_ulogic;
	sw0 : in  std_ulogic;
	pe : in  std_ulogic;
	busy : in  std_ulogic;
	derr : out std_ulogic_vector(3 downto 0)
	);
end errblock;

architecture arc of errblock is
begin
	derr <= pe & sw0 & busy & ce;
end arc;
