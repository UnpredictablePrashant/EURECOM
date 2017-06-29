library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity checksum_test is
end entity checksum_test;

architecture arc of checksum_test is
    signal data_40: std_ulogic_vector(39 downto 0);
    signal CE : std_ulogic; 

begin

    CHECK_CHECKSUM : process(data_40)
        variable computed_checksum : std_ulogic_vector(7 downto 0);
    begin
      computed_checksum := std_ulogic_vector(unsigned(data_40(39 downto 32)) + unsigned(data_40(31 downto 24)) + unsigned(data_40(23 downto 16)) + unsigned(data_40(15 downto 8))) ;
      if (computed_checksum /= data_40(7 downto 0)) then
        CE <= '1';
      else
        CE <='0';
      end if;
    end process;

    process
      variable l : line;
    begin
      data_40 <= (others => '1');
      wait for 50 us;
      data_40 <= (others => '0');
      wait for 50 us;
      data_40 <= (others => '1');
      wait for 50 us;
      data_40 <= (others => '0');
      wait ;
      end process;

end architecture arc;
