library ieee;
use ieee.std_logic_1164.all;

entity mux_2to1_top is
    port ( sw3 : in  std_ulogic;
           dsel   : in  std_ulogic_vector (3 downto 0);
           derr   : in  std_ulogic_vector(3 downto 0);
           dshow   : out std_ulogic_vector  (3 downto 0));
end mux_2to1_top;

architecture Behavioral of mux_2to1_top is
begin
    dshow <= dsel when (sw3 = '1') else derr;
end Behavioral;
