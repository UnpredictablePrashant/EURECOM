use std.textio.all;
use std.env.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

entity ct_sim is
	generic(ncycles: natural := 1000000);
end ct_sim;

ARCHITECTURE BHV OF ct_sim IS

    signal switch0: std_ulogic := '0';
    signal wire_in: std_ulogic := '1';
    signal wire_out: std_ulogic;
    signal led: std_ulogic_vector(3 downto 0);
    signal CLK: bit;

BEGIN

    DefSwitch : Process(CLK)
    begin
        if (CLK = '1' AND CLK'EVENT) THEN
            switch0 <= '1';
        else
            switch0 <= '0';
        end if;
    End Process;

    DefWireIn : Process(CLK)
    begin
        if (CLK = '1' AND CLK'EVENT) THEN
            wire_in <= '1';
        end if;
    end process;

    SeeLedResults: Postponed Process
        variable expectedResult: std_ulogic_vector(3 downto 0);
        variable l: line;
    begin
        wait on led, wire_in, wire_out, switch0;
        expectedResult := (not wire_in) & wire_in & "01";
        write(l, string'("************************************************************"));
	    writeline(output, l);
        if led = expectedResult then
		    write(l, string'("***** YOUR RESULT IS CORRECT"));
		    writeline(output, l);
        else
		    write(l, string'("***** YOUR RESULT IS WRONG (GOT "));
		    write(l, led);
		    write(l, string'(", EXPECTED "));
		    write(l, expectedResult); 
		    write(l, string'(")"));
		    writeline(output, l);
        end if;
	    write(l, string'("************************************************************"));
	    writeline(output, l);
    end process;
        

    -- Process that instantiates the clock

    CLOCK_GEN : PROCESS
    BEGIN
      CLK<='0';
      WAIT FOR 20 ns;
      CLK<='1';
      WAIT FOR 20 ns;
    END PROCESS;

    DUT: entity work.ct PORT MAP(switch0 => switch0, wire_in => wire_in, wire_out => wire_out, led => led);

END BHV;
