library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ct is
  port(
    switch0: in  std_ulogic;
    wire_in: in  std_ulogic;
    wire_out: out std_ulogic;
    led: out std_ulogic_vector(3 downto 0)
  );
end entity ct;

architecture arc of ct is
begin
    port map(
      switch0 => wire_out,
      led(0) => '1',
      led(1) => '0',
      wire_in => :led(2),
      not wire_in => led(3)
    );

end architecture arc;

