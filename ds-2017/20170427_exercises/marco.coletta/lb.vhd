library ieee;
use ieee.std_logic_1164.all;

entity lb is
	generic(
		freq:    positive range 1 to 1000;
		timeout: positive range 1 to 1000000
	);

	port(
  		clk       : in      std_ulogic;
  		areset    : in      std_ulogic;
  		led       : out     std_ulogic_vector(3 downto 0)
  	 );
end entity lb;

architecture arc of lb is
  signal ares_to_ff :  std_ulogic;
  signal ff1_to_ff2 :  std_ulogic;
  signal sresetn    :  std_ulogic;
  signal di         :  std_ulogic;
  signal pulse      :  std_ulogic;
  signal led_to_proc:  std_ulogic_vector(3 downto 0);
begin
  ares_to_ff  <= not areset;
	led <= led_to_proc;


  ffd1: process(clk)
  begin
    if(clk'event and clk = '1') then
 	      ff1_to_ff2 <= ares_to_ff;
    end if;
  end process;

  ffd2: process(clk)
  begin
    if(clk'event and clk = '1') then
 	      sresetn <= ff1_to_ff2;
    end if;
  end process;

 shfreg: entity work.sr(arc)
     port map(
          	clk  	  => clk,
         	sresetn   => sresetn,
       		shift 	  => pulse,
 		      di        => di,
		      do    	  => led_to_proc
             );
 timercomp: entity work.timer(arc)
	generic map (
		      freq      => freq,
          timeout   => timeout
	            )
	port map(
          	clk  	  => clk,
         	sresetn   => sresetn,
       		pulse 	  => pulse
              );

  proc: process(clk)
  begin
    if(clk'event and clk = '1') then
	      --di <= led_to_proc;
        if( sresetn = '0') then
	          di <= '1';
        elsif( pulse = '1' ) then
	          di <= led_to_proc(1);
	      end if;
    end if;
   end process;
end architecture arc;
