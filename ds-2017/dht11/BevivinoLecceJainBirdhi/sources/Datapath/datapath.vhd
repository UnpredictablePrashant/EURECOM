library IEEE;
use IEEE.std_logic_1164.all;

entity datapath is
	generic(freq : positive range 1 to 1000 );-- Clock frequency (MHz)
  Port(
	mclk: in std_ulogic;
	rstsn_sr: in std_ulogic;
	shift_sr: in std_ulogic;
	rstsn_sampler: in std_ulogic;
	start_sampler: in std_ulogic;
	check_20_40: in std_ulogic;
	check_80: in std_ulogic;
	check_50: in std_ulogic;
	check_70: in std_ulogic;
	check_26_28: in std_ulogic;
	rstsn_checker_value: in std_ulogic;
	rstsn_counter: in std_ulogic;
	count_18ms: in std_ulogic;
	count_23ms: in std_ulogic;
	ack_20_40: out std_ulogic;
	ack_80: out std_ulogic;
	ack_50: out std_ulogic;
	ack_70: out std_ulogic;
	ack_26_28: out std_ulogic;
	rdy_samp_meas: out std_ulogic;
	finish_18ms: out std_ulogic;
	finish_23ms: out std_ulogic;
	dout: out std_ulogic_vector(39 downto 0);
	sensor_port:in std_ulogic;
	sr_input: in std_ulogic	     
      );
             
  end datapath;

architecture arc of datapath is


signal shift_parallel_output: std_ulogic_vector(39 downto 0);
signal value_sampler: integer range 0 to 24000;

begin
	
-------------------------------------------------
--component instatiation
-------------------------------------------------

c_checker: entity work.global_checker(arc) 
	generic map(freq => freq)	
	port map(
	gclk => mclk,
	sresetn_checker => rstsn_checker_value,
	check_20_40us => check_20_40,
	check_80us => check_80,
	check_50us => check_50,
	check_70us => check_70,
	check_26_28us => check_26_28,
	ack_20_40us => ack_20_40,
	ack_80us => ack_80,
	ack_50us => ack_50,
	ack_70us => ack_70,
	ack_26_28us => ack_26_28,
	sampled_value => value_sampler);

c_sampler: entity work.sampler2(rtl) 
	port map(
	clk => mclk,
	start_sampl => start_sampler,
	serial_data_in => sensor_port,
	rstsn => rstsn_sampler,
	meas_rdy => rdy_samp_meas,
	sample_value => value_sampler);

c_shift_register: entity work.sr(arc) 
	generic map(N => 40)
	port map(
	    clk => mclk,
	    sresetn => rstsn_sr,
	    shift => shift_sr,
	    di => sr_input,
	    do => shift_parallel_output);


c_counter: entity work.counter_master(struct)
	generic map(freq => freq)
	port map(
		gclk => mclk,
		grstsn => rstsn_counter,
		count_18 => count_18ms,
		count_23 => count_23ms,
		finished_18 => finish_18ms,
		finished_23 => finish_23ms);
             
-------------------------------------------------
dout <=  shift_parallel_output;
end arc;
		
