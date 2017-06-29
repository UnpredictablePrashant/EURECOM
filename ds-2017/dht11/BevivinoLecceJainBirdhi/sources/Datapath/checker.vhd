library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.MATH_REAL.ALL;


entity checker is
  Generic (	N : integer := 8; --values are given in microseconds
		low_lim : integer := 7;
		freq : positive range 1 to 1000;-- Clock frequency (MHz)
		up_lim : integer := 9);
  Port(
	     clk: in std_ulogic;
	     sresetn: in std_ulogic; 
         check_value: in std_ulogic;
	     input_value: in integer;
	     ack_value: out std_ulogic
      );
             
  end checker;

architecture arc of checker is

    begin
	process(clk)
	variable store: integer := 0;
	constant UP_VALUE: integer := freq*up_lim;
	constant LOW_VALUE: integer := freq*low_lim;
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
		
