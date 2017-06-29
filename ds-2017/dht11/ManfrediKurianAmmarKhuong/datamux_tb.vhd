-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

-- Simulation environments are frequently back boxes
entity datamux_tb is
end entity datamux_tb;

architecture sim of datamux_tb is

    signal sw: std_ulogic_vector(2 downto 0):= "000";
    signal d_in: std_ulogic_vector(31 downto 0) := x"00000000";
    signal d_out: std_ulogic_vector(3 downto 0) := "1111";

begin

  -- entity instantiation of the Design Under Test
    dut: entity work.datamux(arc)
        port map(
            sw  => sw,
            d_in => d_in,
            d_out => d_out
        );

    tb : process
    begin
        d_in <= "01110110010101000011001000010000"; --"0111 0110 0101 0100 0011 0010 0001 0000 11111111"
        sw <= "000";
        wait for 10 ns;
       
        sw <= "100"; 
        wait for 10 ns;
        
        sw <= "010";
        wait for 10 ns;

        sw <= "110";
        wait for 10 ns;

        sw <= "001";
        wait for 10 ns;

        sw <= "101"; 
        wait for 10 ns;
    
        sw <= "011";
        wait for 10 ns;

        sw <= "111";
        wait for 10 ns;


        d_in <= "11111110110111001011101010011000"; --"1111 1110 1101 1100 1011 1010 1001 1000 00000000"

        sw <= "000";
        wait for 10 ns;
       
        sw <= "100"; 
        wait for 10 ns;
        
        sw <= "010";
        wait for 10 ns;

        sw <= "110";
        wait for 10 ns;

        sw <= "001";
        wait for 10 ns;

        sw <= "101"; 
        wait for 10 ns;
    
        sw <= "011";
        wait for 10 ns;

        sw <= "111";
        wait for 10 ns;

    end process tb;
end architecture sim;

