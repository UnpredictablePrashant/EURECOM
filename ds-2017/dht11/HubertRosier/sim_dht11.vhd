library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sim_dht11 is
  generic(
           freq: integer := 125 -- 125 MHz 
         );
end entity sim_dht11;

architecture arc of sim_dht11 is 
  signal data: std_logic;
  signal CLK: std_ulogic;
  signal RST: std_ulogic;
  signal SW0: std_ulogic;
  signal SW1: std_ulogic;
  signal SW2: std_ulogic;
  signal SW3: std_ulogic;
  signal BTN: std_ulogic;
  signal LED: std_ulogic_vector(3 downto 0);

begin
  dut: entity work.dht11_top(rtl)
  generic map(
               freq    => freq
             )
  port map(
            data=>  data,
            CLK =>  CLK,
            RST =>  RST, 
            SW0 =>  SW0, 
            SW1 =>  SW1, 
            SW2 =>  SW2, 
            SW3 =>  SW3, 
            BTN =>  BTN, 
            LED =>  LED 
          );

  CLK_GEN : process
    variable half_period: time := integer(1000 / freq) * 0.5 ns; -- to make the clock run at the right frequency
  begin
    CLK <= '0';
    wait for half_period ;
    CLK <= '1';
    wait for half_period ;
  end process;


  process
    variable l : line;
  begin 
    wait for 1 us;
    write(l, String'(""));
    writeline(output,l);
    wait for 30 us;
    writeline(output,l);
    wait for 10 us;
    write(l, String'(""));
    writeline(output,l);
    wait for 50 us;
    writeline(output,l);
    wait ;
  end process;

end architecture arc;
