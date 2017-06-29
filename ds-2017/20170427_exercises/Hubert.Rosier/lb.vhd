library ieee;
use ieee.std_logic_1164.all;

entity lb is
  generic (
  freq: positive range 1 to 1000;
  timeout: positive range 1 to 1000000
);
port (
       clk:  in  std_ulogic;
       areset:  in  std_ulogic;
       led : out std_ulogic_vector (3 downto 0)
     );
end entity lb;

architecture arc of lb is 
  signal tmp_pulse: std_ulogic;
  signal di: std_ulogic;
  signal sresetn: std_ulogic;
  signal led_tmp: std_ulogic_vector (3 downto 0);

begin
  shift_reg: entity work.sr(arc)
  port map (
             clk => clk,
             sresetn => sresetn,
             di => di,
             do => led_tmp,
             shift => tmp_pulse
           );
  timer: entity work.timer(arc)
  generic map(
            freq => freq,
            timeout => timeout
          )
  port map(
            clk => clk,
            sresetn => sresetn,
            pulse => tmp_pulse
          );

  led <= led_tmp;
  -- Inverter and 2 stage register
  process (clk)
    variable tmp: std_ulogic;
  begin
    if rising_edge(clk) then
      sresetn <= tmp;
      tmp := not areset;  
    end if ;
  end process;

 -- process to insert one bit 
 process (clk)
   variable insert : bit ;
 begin 
   if rising_edge(clk) then
     di <= di;
     if sresetn = '0' then
       insert := '1' ;
       di <= '1';
     elsif tmp_pulse = '1' then 
       di <= led_tmp(1);
       if insert = '1' then
         insert := '0';
       end if;
     end if;
   end if;
 end process;


end arc;
