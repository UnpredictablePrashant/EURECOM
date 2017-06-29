-- DTH11 controller

library ieee;
use ieee.std_logic_1164.all;

-- Read data (do) format:
-- do(39 downto 24): relative humidity (do(39) = MSB)
-- do(23 downto 8):  temperature (do(23) = MSB)
-- do(7 downto 0):   check-sum = (do(39 downto 32)+do(31 downto 24)+do(23 downto 16)+do(15 downto 8)) mod 256
entity dht11_ctrl is
	generic(
		freq:    positive range 1 to 1000 -- Clock frequency (MHz)
	);
	port(
		clk:      in  std_ulogic;
		srstn:    in  std_ulogic; -- Active low synchronous reset
		start:    in  std_ulogic;
		data_in:  in  std_ulogic;
		data_drv: out std_ulogic;
		pe:       out std_ulogic; -- Protocol error
		b:        out std_ulogic; -- Busy
		do:       out std_ulogic_vector(39 downto 0) -- Read data
	);
end entity dht11_ctrl;

architecture rtl of dht11_ctrl is
	signal	timer_rst :	std_ulogic;	
	signal	count :		natural;
	signal	shift :		std_ulogic;	
	signal	D_in :		std_ulogic;	
	signal	rise :		std_ulogic;	
	signal	fall :		std_ulogic;	
	signal	pe_local :		std_ulogic;	
begin
	pe <= pe_local;

	u0: entity work.sipo(arc)
	port map(
		clk	=> clk,
		srstn	=> srstn,
		D_in	=> D_in,
		shift	=> shift,
		pe      => pe_local,
		do 	=> do
	);

	u1: entity work.timer(arc)
        generic map(
                freq    => freq
        )
        port map(
                clk     => clk,
                sresetn   => srstn,
                timer_rst   => timer_rst,
		count 	=> count
        );

        u2: entity work.fsm(arc)
        port map(
                clk     => clk,
                srstn   => srstn,
		count	=> count,
		start	=> start,
		shift	=> shift,
		dout_sipo => D_in,
		b	=> b,
		pe	=> pe_local,
		data_drv => data_drv,
		timer_rst => timer_rst,
		rise	=> rise,
		fall	=> fall
        );

        u3: entity work.syncdata(arc)
        port map(
                clk     => clk,
                srstn   => srstn,
                d_in => data_in,
                rise    => rise,
                fall    => fall
        );

end architecture rtl;
