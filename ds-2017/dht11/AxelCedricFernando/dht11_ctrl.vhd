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
	signal fsm_rst : std_ulogic;
	signal cpt : natural;
	signal shift : std_ulogic;
	signal pe_local : std_ulogic;
	signal dsensor : std_ulogic;
	signal dsi : std_ulogic;
	signal timeout : positive range 1 to 1500000;
	signal fsm_reset : std_ulogic;
	signal pulse : std_ulogic;
	signal ce : std_ulogic;
	signal sw0: std_ulogic;
	signal dth : std_ulogic_vector (39 downto 8);
	signal sr_chk: std_ulogic_vector (7 downto 0);
	signal derr: std_ulogic_vector (3 downto 0);

begin
	u0: entity work.sr(arc)
	port map(
		clk => clk,
		sresetn => srstn,
		shift => shift,
		dsi => dsi,
		dth => dth,
		do => do,
		sr_chk => sr_chk
	);
	
	u1: entity work.timer(arc)
	generic map(
		freq => freq
	)	
	port map(
		clk => clk,
		sresetn => srstn,
		timeout => timeout,
		fsm_reset => fsm_reset,
		pulse => pulse
	);

	u2: entity work.fsm(arc)
	port map(
		clk => clk,
		beg => start,
		sresetn => srstn,
		dsensor => dsensor,
		pulse => pulse,
		data_drv => data_drv,
		fsm_reset => fsm_reset,
		pe => pe,
		busy => b,
		timeout => timeout,
		shift => shift,
		dsi => dsi
	);
	u3: entity work.edge_detector(arc)
	port map(
		clk => clk,
		data_in => data_in,
		sresetn => srstn,
		dsensor => dsensor
	);
	u4: entity work.errblock(arc)
	port map(
		ce => ce,
		sw0 => sw0,
		pe => pe,
		busy => b,
		derr => derr
	);
end architecture rtl;
