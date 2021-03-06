-- DTH11 controller wrapper, standalone version

library ieee;
use ieee.std_logic_1164.all;

entity dht11_sa is
	generic(
		freq:    positive range 1 to 1000 -- Clock frequency (MHz)
	);
	port(
		clk:      in  std_ulogic;
		rst:      in  std_ulogic; -- Active high synchronous reset
		btn:      in  std_ulogic;
		sw:       in  std_ulogic_vector(3 downto 0); -- Slide switches
		data_in:  in  std_ulogic;
		data_drv: out std_ulogic;
		led:      out std_ulogic_vector(3 downto 0) -- LEDs
	);
end entity dht11_sa;

architecture rtl of dht11_sa is

	signal srstn: std_ulogic;
	signal start: std_ulogic;
	signal pe:    std_ulogic;
	signal b:     std_ulogic;
	signal do:    std_ulogic_vector(39 downto 0);

begin

	srstn <= not rst;

	deb: entity work.debouncer(rtl)
	port map(
		clk   => clk,
		srstn => srstn,
		d     => btn,
		q     => open,
		r     => start,
		f     => open,
		a     => open
	);

	u0: entity work.dht11_ctrl(rtl)
	generic map(
		freq => freq
	)
	port map(
		clk      => clk,
		srstn    => srstn,
		start    => start,
		data_in  => data_in,
		data_drv => data_drv,
		pe       => pe,
		b        => b,
		do       => do
	);

end architecture rtl;
