library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter_master is
	generic(freq : positive range 1 to 1000 );-- Clock frequency (MHz)
	port(	gclk:	in std_ulogic;
		grstsn:	in std_ulogic;
		count_18: in std_ulogic;
		count_23: in std_ulogic;
		finished_18: out std_ulogic;
		finished_23: out std_ulogic
	);
end counter_master;

architecture struct of counter_master is

     --Component Instantiation 
	begin 
	c1: entity work.counter(behv) 
		generic map(N => 18, freq =>freq)
		port map(
			clk => gclk,
			rstsn => grstsn,
			count => count_18,
			finished => finished_18
		);
	c2: entity work.counter(behv)  
		generic map(N => 23, freq =>freq)
		port map(
			clk => gclk,
			rstsn => grstsn,
			count => count_23,
			finished => finished_23
		);	
	
end struct;
