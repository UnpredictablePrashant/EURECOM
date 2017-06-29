library ieee;
use ieee.std_logic_1164.all;

entity timer is
	generic( 		
		freq:    positive range 1 to 1000; 		
		timeout: positive range 1 to 1000000 	
	);  

	port(	
  		clk       : in      std_ulogic;
  		sresetn   : in      std_ulogic;
  		pulse     : out     std_ulogic
  	 );
end entity timer;

architecture arc of timer is
  signal counter_1 :  integer;
  signal counter_2 :  integer; 
  signal tick      :  std_ulogic;
begin
  
  shr: process(clk)
  begin    
    if(clk'event and clk = '1') then
	pulse <= '0';
	tick  <= '0';
        if(sresetn = '0') then
	    counter_1 <= freq - 1;
	    counter_2 <= timeout - 1;
        else
	    if(counter_1 = 0) then
	      counter_1 <= freq - 1;
    	      tick <= '1';
	    else
              counter_1 <= counter_1 - 1;
	    end if;
	    if(tick = '1') then	
		    if(counter_2 = 0) then
		      counter_2 <= timeout - 1;
	    	      pulse <= '1';
		    else
		      counter_2 <= counter_2 - 1;
		    end if; 
	    end if;
	end if;
    end if;
   end process;
end architecture arc;
