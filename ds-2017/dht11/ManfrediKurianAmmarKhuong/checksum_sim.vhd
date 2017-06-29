library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity checksum_sim is
end entity checksum_sim;

architecture sim of checksum_sim is
 signal do : std_ulogic_vector(39 downto 0);
 signal ce : std_ulogic;
 
begin
 --entity instantiation of the Design Under Test
 dut: entity work.checksum(arc)
  port map(
   do => do,
   ce => ce);
 process
 begin
  --got complete 40 bits data
  do <= "0000000000000000000000000000000100000001";
  wait for 100 ps;

  do <= "0000000000000000000000010000000100000010";
  wait for 100 ps;

  do <= "0000000000000001000000010000000100000011";
  wait for 100 ps;

  do <= "0000000000000000000000000000000100000111";
  wait for 100 ps;

  do <= "0000000000000001000000010000000100000011";
  wait for 100 ps; 

  do <= "1111111111111111111111111111111111111111";
  wait for 100 ps;
 end process;
end architecture sim;
