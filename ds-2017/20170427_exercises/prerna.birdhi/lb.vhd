library ieee;
use ieee.std_logic_1164.all;

entity lb is
        generic(
                freq:   positive range 1 to 1000     := 100;
                timeout:positive range 1 to 1000000  := 500000
        );

        port(
                clk    : in std_ulogic;
                areset : in std_ulogic;
                led    : out std_ulogic_vector(3 downto 0)
         );
end entity lb;

architecture arc of lb is

        signal sresetn:            std_ulogic;
        signal pulse:              std_ulogic;
        signal di:                 std_ulogic;
        signal first_di:           std_ulogic;
        signal led_local:          std_ulogic_vector(3 downto 0);
  
begin
        led <= led_local;
        di  <= led_local(0) or (first_di and pulse);

        u0: entity work.sr(arc)
        port map(
                clk     => clk,
                sresetn => sresetn,
                shift   => pulse,
                di      => di,
                do      => led_local
   );

       u1:entity work.timer(arc)
       generic map(
               freq   => freq,
               timeout=> timeout
  )
  port map(
          clk    => clk,
          sresetn=> sresetn,
          pulse  => pulse
  );

  process(clk)
          variable tmp: std_ulogic;
  begin
          if rising_edge(clk) then
                  sresetn <= tmp;
                  tmp := not areset;
          end if;
  end process;
  
    process(clk)
            variable first_time: boolean;
    begin
            if rising_edge(clk) then
                     if sresetn = '0' then
                             first_di <= '1';
                     elsif pulse = '1' then
                             first_di <= '0';
                  end if;
          end if;
    end process;
end architecture arc;
               
