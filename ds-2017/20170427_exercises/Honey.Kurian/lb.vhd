library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lb is 
 generic (
 freq : positive range 1 to 1000;
 timeout : positive range 1 to 1000000);
 port ( 
 clk : in std_ulogic;
 areset : in std_ulogic;
 led : out std_ulogic_vector(3 downto 0));
end entity lb;

architecture arc of lb is

signal sresetn : std_ulogic;
signal di : std_ulogic;
signal pulse : std_ulogic;
signal first_bit : std_ulogic;
signal led_local : std_ulogic_vector(3 downto 0);

begin
 led <= led_local;
 di <= led_local(0) or (first_bit and pulse);

 --instantiate shift register--
 shiftreg: entity work.sr(arc)
  port map(
   clk => clk,
   do => led_local,
   sresetn => sresetn,
   shift => pulse,
   di => di
  );
 -- instantiate timer--
 timerreg: entity work.timer(arc)
  generic map(
  freq => freq,
  timeout => timeout)
  port map(
  clk => clk,
  pulse => pulse,
  sresetn => sresetn);

 p2 : process(clk)
  variable tmp : std_ulogic;
  begin
   if rising_edge(clk) then
    sresetn <= tmp;
    tmp := not areset;
   end if; 
 end process p2;

 p3 : process(clk)
  variable first_bit : std_ulogic;
  begin
   if rising_edge(clk) then
    if(sresetn = '0') then
     first_bit := '1';
    elsif(pulse = '1') then
     first_bit := '0';
    end if;
   end if;
 end process p3;

end architecture arc;

 
