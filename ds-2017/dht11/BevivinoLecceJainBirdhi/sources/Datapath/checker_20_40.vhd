library IEEE;
use IEEE.std_logic_1164.all;

entity checker_20_40 is
	 Generic (freq : positive range 1 to 1000 );-- Clock frequency (MHz)
  Port(
	     clk: in std_ulogic;
	     sresetn: in std_ulogic; 
         check_value: in std_ulogic;
	     input_value: in integer;
	     ack_value: out std_ulogic
      );
             
  end checker_20_40;

architecture arc of checker_20_40 is

    begin
	process(clk)
	variable store: integer := 0;
	constant UP_VALUE: integer := freq*52;
	constant LOW_VALUE: integer := freq*10;
	begin
		if rising_edge(clk) then 			
			if sresetn = '0' then -- synchronous, active low, reset
				ack_value <= '0';
				store := 0;
			else		
				if (check_value = '1') then 
					store := input_value;
					if (store <= UP_VALUE and store >= LOW_VALUE) then
						ack_value <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

end arc;
		
