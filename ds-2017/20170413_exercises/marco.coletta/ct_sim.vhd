library ieee;
library std;
use ieee.std_logic_1164.all;
use std.env.all;




entity	ct_sim is
	generic(ncycles: natural := 1000000);
end entity ct_sim;

architecture sim of ct_sim is

  signal test_switch0  :   std_ulogic;
  signal test_wire_in  :   std_ulogic;
  signal test_wire_out :   std_ulogic;
  signal test_led      :   std_ulogic_vector( 3 DOWNTO 0);
  signal CLK	       :   std_ulogic;

begin

  
  CLOCK_GEN : process
  begin
    CLK<='0';
    wait for 20 ns;
    CLK<='1';
    wait for 20 ns;
  end process;


  SWITCH0PROC : process
  begin
      test_switch0 <= '0';
      wait for 200 ns;
      test_switch0 <= '1';
      wait for 200 ns;
  end process;  

  TESTWIREINPROC : process
  begin
      test_wire_in <= '0';
      wait for 200 ns;
      test_wire_in <= '1';
      wait for 400 ns;
  end process; 


 
  STOPPROCES: process

  begin
	for i in 0 to ncycles loop
		wait until clk'event and clk = '1';
	end loop;
	stop;
  end process; 


  DUT: entity work.ct(arc)
	port map(switch0  => test_switch0, wire_in  => test_wire_in,
		 wire_out => test_wire_out, led => test_led);


end architecture sim;
