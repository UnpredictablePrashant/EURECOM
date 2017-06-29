use std.textio.all;
--use std.env.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

entity mac_tb is
	generic(ncycles: natural := 1000000);
end mac_tb;

ARCHITECTURE BHV OF mac_tb IS

  SIGNAL A,B,Q,RD_Q,RESULT: INTEGER;
  SIGNAL A_RST, CLK: BIT;
  SIGNAL S: BIT := '0';

BEGIN

-- Process that instantiates the clock

CLOCK_GEN : PROCESS
BEGIN
  CLK<='0';
  WAIT FOR 20 ns;
  CLK<='1';
  WAIT FOR 20 ns;
END PROCESS;

-- Process that creates randomly generated numbers

RANDOM_NUM_GEN : process(CLK)
  variable seed1, seed2: positive;                      -- seed values for random generator
  variable rand1,rand2: real;                           -- random real-number value in range 0 to 1.0
  variable range_of_rand : real := 1000.0;              -- the range of random values created will be 0 to +1000.
BEGIN
  IF(CLK = '1' AND CLK'EVENT) THEN
    uniform(seed1, seed2, rand1);                     -- generate random number
    uniform(seed1, seed2, rand2);
    A <= integer(rand1*range_of_rand);                -- rescale to 0..1000, convert integer part
    B <= integer(rand2*range_of_rand);
  END IF;
END PROCESS;

-- Process used to assign the Reset signal

Reset: PROCESS
BEGIN
  A_RST <= '1';
  WAIT FOR 200 ns;
  A_RST <= '0';
  WAIT;
END PROCESS;

-- Process used to assign the Mux selection signal

Mux_signal: PROCESS
BEGIN
  S <= not S;
  for i in 1 to 10 loop
	  wait until rising_edge(clk);
  end loop;
END PROCESS;

--This is the process that recreates the accumulator to be compared with the DUT

Rd: PROCESS(A_RST,CLK)
	variable l: line;
BEGIN
  IF(A_RST='0') THEN
    IF(CLK'EVENT AND CLK='1') THEN
      IF(S='1') THEN
        RD_Q<=A+B;
      ELSE
        RD_Q<=RD_Q+A;
      END IF;
    end IF;
    IF(CLK'EVENT and CLK='0') THEN
	    if rd_q /= q then
		    write(l, string'("************************************************************"));
		    writeline(output, l);
		    write(l, string'("***** YOUR RESULT IS WRONG (GOT "));
		    write(l, q);
		    write(l, string'(", EXPECTED "));
		    write(l, rd_q);
		    write(l, string'(")"));
		    writeline(output, l);
		    write(l, string'("************************************************************"));
		    writeline(output, l);
		    assert false severity failure;
	    end if;
    end IF;
  ELSE
    RD_Q<=0;
  END IF;
END PROCESS;

-- This is a process used to compare the two results: DUT AND TEST_BENCH (IF RESULT = 1 GOOD!)

Check: PROCESS(Q,RD_Q)
BEGIN
  IF(RD_Q=Q) THEN
    RESULT<=1; --RESULT = 1 means good result
  ELSE
    RESULT<=0;
  END IF;
END PROCESS;

stopper: process
	variable l: line;
begin
	write(l, string'("************************************************************"));
	writeline(output, l);
	write(l, string'("***** SIMULATING FOR "));
	write(l, ncycles);
	write(l, string'(" CLOCK CYCLES. PLEASE WAIT..."));
	writeline(output, l);
	write(l, string'("************************************************************"));
	writeline(output, l);
	for i in 0 to ncycles loop
		wait until clk'event and clk = '1' and a_rst = '0';
	end loop;
	write(l, string'("************************************************************"));
	writeline(output, l);
	write(l, string'("***** NON-REGRESSION TEST PASSED. CONGRATULATIONS!"));
	writeline(output, l);
	write(l, string'("************************************************************"));
	writeline(output, l);
	assert false;
end process stopper;

DUT: entity work.accumulator PORT MAP(Clk => CLK, A_Rst => A_RST, A => A,B => B,S => S, Q => Q);
END BHV;
