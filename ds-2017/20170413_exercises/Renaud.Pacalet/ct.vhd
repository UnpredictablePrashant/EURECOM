-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity ct is
  port(
    switch0:  in  std_ulogic;
    wire_in:  in  std_ulogic;
    wire_out: out std_ulogic;
    led:      out std_ulogic_vector(3 downto 0)
  );
end entity ct;

architecture arc of ct is
begin
  wire_out <= switch0; -- concurrent signal assignments are shorthands for the (trivial) equivalent processes
  led      <= (not wire_in) & wire_in & "01"; -- & is the concatenation operator
end architecture arc;
