library ieee; 
use ieee.std_logic_1164.all; 

entity lb is
	generic(
		freq:    positive range 1 to 1000;	
		timeout: positive range 1 to 1000000);
	port(
		clk:      in  std_ulogic;
		areset:   in  std_ulogic;
		led:      out std_ulogic_vector(0 to 3)
	);
end entity lb;

architecture arc of lb is

	signal sresetn:		std_ulogic;
	signal pulse:		std_ulogic;
	signal di:		std_ulogic;
	signal first_bit:	std_ulogic;
	signal led_local:	std_ulogic_vector(0 to 3);

begin
	led <= led_local;
	di  <= led_local(0) or (first_bit and pulse);

	s_reg: entity work.sr(arc)
	port map(
		clk	=> clk,
		sresetn	=> sresetn,
		shift	=> pulse,
		di	=> di,
		do	=> led_local);

	timer: entity work.timer(arc)
	generic map(
		freq	=> freq,
		timeout	=> timeout)
	port map(
		clk	=> clk,
		sresetn	=> sresetn,
		pulse	=> pulse);

	process(clk)
		variable temp: std_ulogic;
	begin
		if rising_edge(clk) then
			sresetn<=temp;
			temp:=not areset;
		end if;
	end process;

	process(clk)
		variable first_bit: std_ulogic;
	begin
		if rising_edge(clk) then
			first_bit:='0';	
		end if;
	end process;
end architecture arc;
