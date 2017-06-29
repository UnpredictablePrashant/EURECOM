library IEEE; 
use ieee.numeric_std.all;
--use ieee.std_ulogic.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;



entity d_select_mux2_tb is
end entity d_select_mux2_tb;

architecture sim of d_select_mux2_tb is 

  signal  PE:     std_ulogic := '0';
  signal  B:     std_ulogic := '0';
  signal  CE:    std_ulogic := '0';
  signal  SW:   std_ulogic_vector(1 downto 0) := "01";
  signal MUX_DO: std_ulogic_vector(3 downto 0) := "0000";
  signal  led:   std_ulogic_vector(3 downto 0); -- no initialisation

begin
 -- entity instantiation of the Design Under Test
    dut: entity work.d_select_mux2(arc)
        port map(
            PE => PE,
	    CE => CE,
	    B => B,
            SW => SW,
            MUX_DO => MUX_DO,
            led => led
        );
tb : process
    begin
        mux_do <= "0000";

        -- SW(3)=0 ---> led = PE|SW(0)|B|CE
	-- led = 1100
	SW <= "01";
        PE <= '1';
        B <= '0';
        CE <= '0';
        mux_do <= "0110";
	wait for 10 ns;
        
	-- led = 0011
	SW <= "00";
        PE <= '0';
        B <= '1';
        CE <= '1';
        mux_do <= "1100";
	wait for 10 ns;

	-- led = 0000
	SW <= "00";
        PE <= '0';
        B <= '0';
        CE <= '0';
        mux_do <= "0101";
	wait for 10 ns;

        -- SW(3)=1 ---> led = mux_do
	-- led = 0110
	SW <= "11";
        PE <= '1';
        B <= '0';
        CE <= '0';
        mux_do <= "0110";
	wait for 10 ns;
        
	-- led = 1100
	SW <= "10";
        PE <= '0';
        B <= '1';
        CE <= '1';
        mux_do <= "1100";
	wait for 10 ns;

	-- led = 0101
	SW <= "10";
        PE <= '0';
        B <= '0';
        CE <= '0';
        mux_do <= "0101";
	wait for 10 ns;

    end process tb;
end architecture sim;


