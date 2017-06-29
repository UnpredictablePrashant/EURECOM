library ieee;
use ieee.std_logic_1164.all;


entity sr is
    Port ( CLK : in  STD_LOGIC;
           D   : in  STD_LOGIC;
           LED : out STD_LOGIC_VECTOR(7 downto 0));
end sr;
    
architecture arc of sr is
    signal clock_div : STD_LOGIC_VECTOR(4 downto 0);
    signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := X"00";
begin

--reloj--
    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            clock_div <= clock_div + '1';
        end if;
    end process;
