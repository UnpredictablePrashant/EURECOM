library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compt_test is
  generic(
           freq: integer := 125 -- 125 MHz
         );
end entity compt_test;

architecture arc of compt_test is 
  signal RST_COUNT: std_ulogic;
  signal sresetn : std_ulogic;
  signal CLK: std_ulogic;
  signal pulse: std_ulogic;
  signal count: integer;

begin

  -- TIMER --
    timer0 : entity work.timer(arc)
    generic map(
                   freq => freq,
                   timeout => 1
               )
    port map(
                clk => CLK,
                sresetn => sresetn,
                pulse => pulse
            );
  
  CLK_GEN : process
    variable half_period: time := 4 ns; -- to make the clock run at the right frequency
  begin
    CLK <= '0';
    wait for half_period ;
    CLK <= '1';
    wait for half_period ;
  end process;

  ARESET_TO_SRESETN : process(CLK)
      variable reset_inter : std_ulogic;
  begin
      if CLK'event and CLK='1' then
          sresetn <= reset_inter ;
          reset_inter := not RST_COUNT;
      end if;
  end process;

  COMPT: process(clk)
  begin
      if clk'event and clk='1' then
          if RST_COUNT = '1' then
              count <= 0;
          elsif pulse = '1' then
              count <= count + 1;
          end if;
      end if;
  end process;

  process
    variable l : line;
  begin 
    wait for 1 us;
    RST_COUNT <= '1'; 
    write(l, String'("We start waiting for 30 us"));
    writeline(output,l);
    wait for 30 us;
    write(l, String'("The main process has waited for 30 us and the compteur has counted: ") & to_string(count) & String'(" us"));
    writeline(output,l);
    RST_COUNT <= '0';
    wait for 10 us;
    write(l, String'("We start waiting for 50 us"));
    writeline(output,l);
    wait for 50 us;
    write(l, String'("The main process has waited for 50 us and the compteur has counted: ") & to_string(count) & String'(" us"));
    writeline(output,l);
    wait ;
  end process;

end architecture arc;
