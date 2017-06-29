library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity printer_test is
    end entity printer_test;

architecture arc of printer_test is
        signal data_40: std_ulogic_vector(39 downto 0);
        signal SW0 : std_ulogic;
        signal SW1 : std_ulogic; 
        signal SW2 : std_ulogic;
        signal SW3 : std_ulogic;
        signal CE : std_ulogic := '0';
        signal PE : std_ulogic := '1';
        signal LED : std_ulogic_vector(3 downto 0);

begin

    PRINTER: process(data_40, SW0, SW1, SW2, SW3) -- TODO check with the implementation of read message if data_40 is a sensibility
        variable switches : std_ulogic_vector(2 downto 0);
    begin
        switches := SW0 & SW1 & SW2 ;
        if SW3 = '1' then
            LED(0) <= CE;
            LED(1) <= '0'; --TODO : busy bit
            LED(2) <= SW0;
            LED(3) <= PE;
        else
            case switches is
                when "111" => LED <= data_40(39 downto 36);
                when "110" => LED <= data_40(35 downto 32);
                when "101" => LED <= data_40(31 downto 28);
                when "100" => LED <= data_40(27 downto 24);
                when "011" => LED <= data_40(23 downto 20);
                when "010" => LED <= data_40(19 downto 16);
                when "001" => LED <= data_40(15 downto 12);
                when "000" => LED <= data_40(11 downto 8);
                when others => LED <= "0000";
            end case;
        end if;

    end process;


    process
    begin
        SW3 <= '1';
        SW0 <= '1';
        wait for 50 us;
        SW3 <= '1';
        SW0 <= '0';
        wait for 50 us;
        SW3 <= '0';
        SW0 <= '1';
        SW1 <= '0';
        SW2 <= '1';
        data_40 <= (others => '1');
        data_40(31 downto 28) <= "0000";
        wait for 50 us;
        wait ;
    end process;

end architecture arc;
