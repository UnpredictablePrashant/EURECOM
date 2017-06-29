library ieee;
use ieee.std_logic_1164.all;
entity ct is
    port( 
        switch0: in std_ulogic;
        wire_in: in std_ulogic;
	wire_out: out std_ulogic;
	led: out std_ulogic_vector(3 downto 0)
    );
end entity ct;
architecture arc of ct is

begin    
    P1: process(switch0,wire_in)
    begin
	wire_out<=switch0;
	led(3 downto 0)<= (not wire_in) & wire_in & '0' & '1';
  
    end process;

   
end architecture arc;

