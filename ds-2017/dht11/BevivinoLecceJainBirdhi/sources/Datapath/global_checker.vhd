library IEEE;
use IEEE.std_logic_1164.all;


--values must be given in clock cycles and the confront must be done in microseconds
entity global_checker is
  Generic (freq : positive range 1 to 1000 );-- Clock frequency (MHz)
  Port(
	gclk: in std_ulogic;
	sresetn_checker: in std_ulogic; 
	check_20_40us: in std_ulogic;
	check_80us: in std_ulogic;
	check_50us: in std_ulogic;
	check_70us: in std_ulogic;
	check_26_28us: in std_ulogic;
	ack_20_40us: out std_ulogic;
	ack_80us: out std_ulogic;
	ack_50us: out std_ulogic;
	ack_70us: out std_ulogic;
	ack_26_28us: out std_ulogic;
	sampled_value: in integer range 0 to 24000		
      );
             
  end global_checker;

architecture arc of global_checker is


begin

checker_20_40us: entity work.checker_20_40(arc)  
	generic map(freq=>freq )	
	port map(
	clk => gclk,
	sresetn => sresetn_checker, 
	check_value => check_20_40us,
	input_value => sampled_value,
	ack_value => ack_20_40us
      );


checker_26_28us: entity work.checker_26_28(arc) 
	generic map(freq=>freq )
	port map(
	clk => gclk,
	sresetn => sresetn_checker,
	check_value => check_26_28us,
	input_value => sampled_value,
	ack_value => ack_26_28us
); 

checker_80us: entity work.checker(arc)
	generic map(N => 80, low_lim =>64 ,up_lim=>96, freq=>freq )
	port map(
	clk => gclk,
	sresetn => sresetn_checker,
	check_value => check_80us,
	input_value => sampled_value,
	ack_value => ack_80us
);

checker_50us: entity work.checker(arc)
	generic map(N => 50, low_lim =>35 ,up_lim=>63, freq=>freq)
	port map(
	clk => gclk,
	sresetn => sresetn_checker,
	check_value => check_50us,
	input_value => sampled_value,
	ack_value => ack_50us

);

checker_70us: entity work.checker(arc)
	generic map(N => 70, low_lim =>53 ,up_lim=>87, freq=>freq)
	port map(
	clk => gclk,
	sresetn => sresetn_checker,
	check_value => check_70us,
	input_value => sampled_value,
	ack_value => ack_70us
);


end arc;
		
