library ieee; 
use ieee.std_logic_1164.all; 

entity lb is     
	generic (
		freq : positive range 1 to 1000;
		timeout: positive range 1 to 10000000
	);
	port (
		clk: in std_ulogic ;
		areset: in std_ulogic ;
		led: out std_ulogic_vector(3 downto 0)
	); 
end entity lb;


architecture arc of lb is 
	signal sresetn :  std_ulogic;	 	
	signal pulse:     std_ulogic;
	signal di:        std_ulogic;
	signal do:        std_ulogic_vector(3 downto 0);
	signal shift_used: std_ulogic;
begin     
	dut: entity work.sr(arc)
		port map( 
			clk     => clk, 			
			sresetn => sresetn, 
			shift   => pulse, 
			di      => di, 
			do      => do 
		);

	dut2: entity work.timer(arc)
		generic map( 			
			freq    => freq, 
			timeout => timeout 
		)
		port map( 			
			clk     => clk, 			
			sresetn => sresetn, 
			pulse   => pulse 
		);

	led <= do;  -- current value of the shift register to the led output
	di <= do(0) or (not shift_used and pulse);	
	process (clk, areset)
		variable tmp : std_ulogic;
	begin
		if rising_edge(clk) then
			sresetn <= tmp;
			tmp := not areset;
		end if;

	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if sresetn='0' then
				shift_used <= '0';
			elsif pulse = '1' then
				shift_used <= '1';
			end if;
		end if;
	end process;

end architecture arc;
