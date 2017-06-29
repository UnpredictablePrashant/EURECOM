library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is

generic(N: integer := 30;
	freq : positive range 1 to 1000 );-- Clock frequency (MHz)
port(	clk:	in std_ulogic;
	rstsn:	in std_ulogic;
	count:	in std_ulogic;
	finished: out std_ulogic
);
end counter;

architecture behv of counter is		 		
    signal cnt: integer range 0 to N*freq*1000 +2;

begin

    -- behavior describe the counter
    process(clk)
    variable flag: integer := 0;
	constant COUNT_VALUE: integer := N*freq*1000;
    begin
	if rising_edge(clk) then
		if rstsn = '0' then
			flag := 0;
			cnt <= 0;
			finished <= '0';
		else
			if count = '1' or flag=1 or (count = '1' and flag=1) then
				flag := 1;
				if cnt > COUNT_VALUE then
					finished <= '1';
				else 
					cnt <= cnt + 1;
				end if;
		    	end if;
		end if;
	end if;
    end process;	

end behv;
