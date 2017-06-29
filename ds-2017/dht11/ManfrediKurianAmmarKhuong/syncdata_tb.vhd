use std.textio.all;
--use std.env.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

entity syncdata_tb is
    generic(ncycles: natural := 1000000); -- No idea, just copying from a prof example
end syncdata_tb;

ARCHITECTURE arc OF syncdata_tb IS

  SIGNAL clk, d_in, srstn, rise, fall: std_ulogic := '0';

BEGIN

-- Process that instantiates the clock
-- Nick: How fast should this actually be and does it matter?
CLOCK_GEN : PROCESS
BEGIN
  --while now < 1000 ns loop
  CLK<='0';
  WAIT FOR 20 ns;
  CLK<='1';
  WAIT FOR 20 ns;
  --end loop;
END PROCESS;

-- Process that creates randomly generated numbers which determine how long to hold the input signal

RANDOM_NUM_GEN : process
  variable seed1, seed2: positive;                      -- seed values for random generator
  variable rand1,rand2: real;                           -- random real-number value in range 0 to 1.0
  variable range_of_rand : real := 200.0;              -- the range of random values created will be 10 to +210.
  variable temp: integer;
BEGIN
  srstn <= '1';
  for cnt_val in 0 to 20 loop
      wait until falling_edge(clk);
        uniform(seed1, seed2, rand1);                     -- generate random number
        temp := integer((rand1 * range_of_rand) + 10.0);
        wait for temp * 1 ns;                -- rescale to 10..210, convert integer part
        d_in <= not d_in;
  end loop; 
  
  srstn <= '0';
  for cnt_val in 0 to 20 loop
      wait until falling_edge(clk);
        uniform(seed1, seed2, rand1);                     -- generate random number
        temp := integer((rand1 * range_of_rand) + 10.0);
        wait for temp * 1 ns;                -- rescale to 10..210, convert integer part
        d_in <= not d_in;
  end loop; 
END PROCESS;

-- Process used to assign the Reset signal

--Reset: PROCESS
--BEGIN
--  A_RST <= '1';
--  WAIT FOR 200 ns;
--  A_RST <= '0';
--  WAIT;
--END PROCESS;

-- Process used to assign the Mux selection signal

--Mux_signal: PROCESS
--BEGIN
--  S <= not S;
--  for i in 1 to 10 loop
--    wait until rising_edge(clk);
--  end loop;
--END PROCESS;

DUT: entity work.syncdata PORT MAP(clk => clk, d_in => d_in, srstn => srstn, rise => rise, fall => fall);
END arc;

