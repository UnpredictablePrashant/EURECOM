library IEEE;
use IEEE.std_logic_1164.all;

-- entity ct
entity ct is
    Port ( switch0 : in std_ulogic;
           wire_in : in std_ulogic;
           wire_out : out std_ulogic; 
           led : out std_ulogic_vector(3 downto 0));
end ct;

-- architecture
architecture arc of ct is
begin
    wire_out <= switch0;
    led(0) <= '1';
    led(1) <= '0';
    led(2) <= wire_in;
    led(3) <= not wire_in;
end arc;
