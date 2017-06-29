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
		do:       out std_ulogic_vector(39 downto 0); -- Read data
		FSM_stati:out std_logic_vector(4 downto 0)
	);
end entity dht11_ctrl;

architecture rtl of dht11_ctrl is

signal rst_check:std_ulogic;
signal rst_count:std_ulogic;
signal rst_display:std_ulogic;
signal rst_sr:std_ulogic;
signal rst_checksum:std_ulogic;
signal rst_samp:std_ulogic;
signal ck_80:std_ulogic;
signal ck_50:std_ulogic;
signal ck_70:std_ulogic;
signal ck_20_40:std_ulogic;
signal ck_26_28:std_ulogic;
signal k_80:std_ulogic;
signal k_50:std_ulogic;
signal k_70:std_ulogic;
signal k_20_40:std_ulogic;
signal k_26_28:std_ulogic;
signal shift_in:std_ulogic;
signal shift_cmd:std_ulogic;
signal str_sampl:std_ulogic;
signal measure_ready:std_ulogic;
signal cnt18:std_ulogic;
signal cnt23:std_ulogic;
signal fin18:std_ulogic;
signal protocolerror:std_ulogic;
signal busyaf:std_ulogic;
signal aa,bb,ee:std_ulogic;
signal rst:std_ulogic;
signal stati: std_logic_vector(4 downto 0);
begin
FSM_stati <= stati;
  rst <= not(srstn);
fsm: entity work.fsm(behave)
	port map(
		clk			=>clk,
		rstsn_checker_value	=>rst_check,
		rstsn_counter		=>rst_count,
		rstsn_display		=>rst_display,
		rstsn_sr		=>rst_sr,
		rstsn_checksum		=>rst_checksum,
		rstsn_sampler		=>rst_samp,
		RST_EXT			=>rst,
		check_80us		=>ck_80,
		check_70us		=>ck_70,
		check_50us		=>ck_50,
		check_20_40us		=>ck_20_40,
		check_26_28us		=>ck_26_28,
		ack_80us		=>k_80,
		ack_70us		=>k_70,
		ack_50us		=>k_50,
		ack_20_40us		=>k_20_40,	
		ack_26_28us		=>k_26_28,
		count_18ms		=>cnt18,
		finish_18ms		=>fin18,
		count_23ms		=>cnt23,
		busy			=>busyaf,
		prot_err		=>protocolerror,
		shift_sr		=>shift_cmd,
		rdy_meas		=>measure_ready,
		start_sampler		=>str_sampl,
		start_process		=>start,
		data_drv		=>data_drv,
		input_shift		=>shift_in,
		stati			=>stati

	);


DP: entity work.datapath(arc)
	generic map(freq => freq)
	port map(
		mclk			=>clk,
		rstsn_sr		=>rst_sr,
		shift_sr		=>shift_cmd,
		rstsn_sampler		=>rst_samp,
		start_sampler		=>str_sampl,
		check_20_40		=>ck_20_40,
		check_80		=>ck_80,
		check_50		=>ck_50,
		check_70		=>ck_70,
		check_26_28		=>ck_26_28,
		rstsn_checker_value	=>rst_check,
		rstsn_counter		=>rst_count,
		count_18ms		=>cnt18,
		count_23ms		=>cnt23,
		ack_20_40		=>k_20_40,
		ack_80			=>k_80,
		ack_50			=>k_50,
		ack_70			=>k_70,
		ack_26_28		=>k_26_28,
		rdy_samp_meas		=>measure_ready,
		finish_18ms		=>fin18,
		sensor_port		=>data_in,
		dout			=>do,
		sr_input		=>shift_in
	);
b <= busyaf;
pe <=protocolerror;
end architecture rtl;

