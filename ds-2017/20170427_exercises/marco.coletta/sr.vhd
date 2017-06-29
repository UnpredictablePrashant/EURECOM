library ieee;
use ieee.std_logic_1164.all;

entity sr is
  port(

  		clk       : in     std_ulogic;
  		sresetn   : in     std_ulogic;
  		shift     : in     std_ulogic;
		di        : in     std_ulogic;
  		do	  : out    std_ulogic_vector(3 DOWNTO 0)
  	 );
end entity sr;

architecture arc of sr is
  signal reg :  std_ulogic_vector(3 DOWNTO 0); 
begin
  
  shr: process(clk)
  begin
    if(clk'event and clk = '1') then
        if(sresetn = '0') then
	    reg <= (others=>'0');
        elsif(shift = '1') then
             for i in 0 to 2 loop
           	reg(i) <= reg(i+1);
             end loop;
             reg(3) <= di;
	end if; 			
    end if;
   end process;
   do <= reg;
end architecture arc;
