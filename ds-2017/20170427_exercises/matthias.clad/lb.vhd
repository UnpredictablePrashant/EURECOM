library ieee;
use ieee.std_logic_1164.all;

entity lb is
    generic(freq: positive range 1 to 1000;
            timeout: positive range 1 to 1000000);
    port(clk     : in  std_ulogic;
         areset  : in  std_ulogic;
         led     : out std_ulogic_vector(3 downto 0));
end entity lb;

architecture arc of lb is

signal inter, sresetn, pulse_to_shift, do_int: std_ulogic;
signal first_di: std_ulogic;
signal di_int: std_ulogic;

component sr is
    port(clk     : in std_ulogic;
         sresetn : in std_ulogic;
         shift   : in std_ulogic;
         di      : in std_ulogic;
         do      : out std_ulogic_vector(3 downto 0));
end component sr;

component timer is
    generic(freq: positive range 1 to 1000;
            timeout: positive range 1 to 1000000);
    port(clk     : in  std_ulogic;
         sresetn : in  std_ulogic;
         pulse   : out std_ulogic);
end component timer;

begin

    process(clk)
    begin
        if clk'event and clk='1' then
            inter<=not(areset);
        end if;
    end process;

    process(clk)
    begin
        if clk'event and clk='1' then
            sresetn<=inter;
        end if;
    end process;

    timer_one: entity work.timer(arc) 
    generic map (freq => freq, timeout => timeout)
    port map (
      clk => clk,
      sresetn => sresetn, 
      pulse => pulse_to_shift
    );

    sr_one: entity work.sr(arc) 
    port map (
      clk => clk,
      sresetn => sresetn, 
      shift => pulse_to_shift,
      di => di_int,
      do => led
    );

    do_int <= led(0);
    di_int <= do_int or (first_di and pulse_to_shift);

    process(clk) 		 	
    begin 		
        if rising_edge(clk) then 			
            if sresetn = '0' then			
                first_di <= '1'; 		
	    elsif pulse_to_shift = '1' then 				
                first_di <= '0'; 			
            end if; 
        end if; 	
    end process;

end architecture arc;

