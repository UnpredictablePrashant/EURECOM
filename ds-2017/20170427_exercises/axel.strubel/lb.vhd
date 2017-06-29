-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity lb is
	generic(
		freq:    positive range 1 to 1000 := 100;
		timeout: positive range 1 to 1000000 := 500000
	);
	port(
		clk:      in  std_ulogic;
		areset:  in  std_ulogic;
		led:    out std_ulogic_vector(3 downto 0)
	);
end entity lb;

architecture arc of lb is
	signal sresetn: std_ulogic;
	signal di: std_ulogic;
	signal intern_led: std_ulogic_vector(3 downto 0);
	signal pulse: std_ulogic;
	signal first_input_di: std_ulogic;
begin
	--entity instantiation:
	timer_inst: entity work.timer(arc)
		generic map(
			freq => freq,
			timeout => timeout
		)
		port map(
			clk => clk,
			sresetn =>  sresetn,
			pulse => pulse
		);
	sr_inst: entity work.sr(arc)
		port map(
			clk => clk,
			sresetn => sresetn,
			di => di,
			do => intern_led,
			shift => pulse
		);
	

	P1: process(clk)
		variable tmp: std_ulogic;
	begin	
		if rising_edge(clk) then --this part is implementing the 2stages shift register
			sresetn <= tmp;
			tmp := not areset;
		end if;	
	end process P1; 

	P2: process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				first_input_di <= '1';
			elsif pulse = '1' then
				first_input_di <= '0';		
			end if;
		end if;
	end process P2;
	
	led <= intern_led;
	di <= intern_led(0) or (first_input_di and pulse);		
end architecture arc;
