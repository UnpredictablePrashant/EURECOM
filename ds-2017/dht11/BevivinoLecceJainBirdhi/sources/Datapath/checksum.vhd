library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;

entity checksum is
  Port(
	     sresetn: in std_ulogic; 
             data: in std_ulogic_vector(39 downto 0);
	     ack: out std_ulogic --set high if the checksum is correct
      );
             
  end checksum;

architecture arc of checksum is
        
	signal integralRH: integer range 0 to 200 :=0 ;
    	signal decimalRH: integer range 0 to 200 :=0;
    	signal integralT: integer range 0 to 200 :=0;
    	signal decimalT: integer range 0 to 200 :=0;
    	signal in_checksum: integer range 0 to 200 :=0;
	signal out_checksum: integer range 0 to 200 :=0;
    begin

	process(data,sresetn)
	
	begin
		 			
		integralRH <= 0;
		decimalRH <= 0;
		integralT <= 0;
		decimalT <= 0;
		in_checksum <= 0;
		if sresetn /= '0' then -- synchronous, active low, reset
			integralRH <= to_integer(unsigned(data(39 downto 32)));
			decimalRH <= to_integer(unsigned(data(31 downto 24)));
			integralT <= to_integer(unsigned(data(23 downto 16)));
			decimalT <= to_integer(unsigned(data(15 downto 8)));
			in_checksum <= to_integer(unsigned(data(7 downto 0)));	
		end if;
		
	end process;

	out_checksum <= integralRH + decimalRH + integralT + decimalT ; 	

	ack <= '1' when sresetn = '0' else
	       '0' when out_checksum = in_checksum else
	       '1';

end arc;
		
