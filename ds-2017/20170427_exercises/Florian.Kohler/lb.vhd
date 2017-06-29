library ieee;
use ieee.std_logic_1164.all;

entity lb is
	generic(
		freq:    positive range 1 to 1000;
		timeout: positive range 1 to 1000000
	);
	port(
		clk:      in  std_ulogic;
		areset:   in  std_ulogic;
		led:      out std_ulogic_vector(3 downto 0)
	);
end entity lb;

architecture arc of lb is

	signal sresetn:		std_ulogic;
	signal pulse:		std_ulogic;
	signal di:		std_ulogic;
	signal init_di:		std_ulogic;
	signal myledvar:	std_ulogic_vector(3 downto 0);

begin
	led <= myledvar;
	di  <= myledvar(0) or (init_di and pulse);

	u0: entity work.sr(arc)
	port map(
		clk	=> clk,
		sresetn	=> sresetn,
		shift	=> pulse,
		di	=> di,
		do	=> myledvar
	);

	u1: entity work.timer(arc)
	generic map(
		freq	=> freq,
		timeout	=> timeout
	)
	port map(
		clk	=> clk,
		sresetn	=> sresetn,
		pulse	=> pulse
	);

	shiftinverter: process(clk)
		variable tmp: std_ulogic;
	begin
		if rising_edge(clk) then
			sresetn <= tmp;
			tmp := not areset;
		end if;
	end process;

	thisone: process(clk)
		variable first_time: boolean;
	begin
		if rising_edge(clk) then
			if sresetn = '0' then 
				init_di <= '1';
			elsif pulse = '1' then
				init_di <= '0';
			end if;
		end if;
	end process;
end arc;
