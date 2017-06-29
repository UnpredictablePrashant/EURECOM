library ieee;
use ieee.std_logic_1164.all;

entity selector is
    port ( 
	sw0 : in  std_ulogic;
	sw1 : in  std_ulogic;
 	sw2 : in  std_ulogic;
        dth   : in  std_ulogic_vector (31 downto 0);
        dsel   : out  std_ulogic_vector(3 downto 0));
end selector;

architecture arc of selector is
begin
    process (sw0,sw1,sw2,dth)
    begin
	if (sw0 = '0') then 
		-- Temperature data
		if ((sw1 = '0') and (sw2 = '0')) then 
			-- 4LSB
			dsel <= dth (3 downto 0);
		elsif ((sw2 = '1') and (sw1 = '0')) then 
			-- 5 to 8 LSB
			dsel <= dth (7 downto 4);
		elsif ((sw2 = '0') and (sw1 = '1')) then
                         -- 5 to 8 MSB
			dsel <= dth (11 downto 8);
		elsif ((sw2 = '1') and (sw1 = '1')) then
                         -- 4 MSB
			dsel <= dth (15 downto 12);
		end if;
	else 
		--Humidity data
		if ((sw1 = '0') and (sw2 = '0')) then
                         -- 4LSB
			dsel <= dth (19 downto 16);
                elsif ((sw2 = '1') and (sw1 = '0')) then
                         -- 5 to 8 LSB
			dsel <= dth (23 downto 20);
                elsif ((sw2 = '0') and (sw1 = '1')) then
                         -- 5 to 8 MSB
			dsel <= dth (27 downto 24);
                elsif ((sw2 = '1') and (sw1 = '1')) then
                         -- 4 MSB
			dsel <= dth (31 downto 28);	
		end if;
	end if;
    end process;
end arc;
