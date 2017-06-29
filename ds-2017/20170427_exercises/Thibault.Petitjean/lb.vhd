--has to be compiled with vhdl -2008 because the outputs are read 
LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;

entity lb is
	generic (
		freq : positive range 1 to 1000; -- master clk frequency in MHz
		timeout : positive range 1 to 1000000 -- number of ms between two output pulses
	);
	port (
		clk : in std_ulogic; --master clock. the design is synchro on rising edge of clk
		areset : in std_ulogic; -- async, active high reset
		led : out std_ulogic_vector(3 downto 0) -- will be wired to the 4 user LEDs 
	);
end entity lb;

architecture arc of lb is
	signal sresetn:std_ulogic;	
	signal pulse:std_ulogic;
	signal di:std_ulogic; 	
	signal first_di:std_ulogic; 	
	signal local_led:std_ulogic_vector(3 downto 0);

begin
	
	led <= local_led;
 	di  <= local_led(0) or (first_di and pulse);	
	
	shiftentity : entity work.sr(arc) 
	port map( --on the left, the port from sr
		clk	=> clk,
		sresetn	=> sresetn,
 		shift	=> pulse,
 		di	=> di,
 		do	=> local_led
	);
	
	timerentity :entity work.timer(arc)
	generic map( 
		freq	=> freq,
 		timeout	=> timeout) 	
	port map(clk	=> clk,
 		sresetn	=> sresetn,
 		pulse	=> pulse 	);

	process(clk) 		
		variable temp: std_ulogic; 	
	begin 		
		if rising_edge(clk) then
 			sresetn <= temp; 			
			temp := not areset; 		
		end if; 	
	end process; 	
	
	process(clk) 		
		variable first_time: boolean; 	
	begin 		
		if rising_edge(clk) then 			
			if sresetn = '0' then -- synchronous, active low, reset
				first_di <= '1'; 			
			elsif pulse = '1' then 				
				first_di <= '0'; 			
			end if; 		
		end if; 	
	end process;

end architecture arc;

