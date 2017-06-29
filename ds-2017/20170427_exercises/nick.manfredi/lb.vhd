library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity lb is
        generic(
                freq:    positive range 1 to 1000;
                timeout: positive range 1 to 1000000
                    );
                        port(
                                clk:      in  std_ulogic;
                                areset:  in  std_ulogic;
                                led:    out std_ulogic_vector(3 downto 0)
                                    );
end entity lb;

architecture arc of lb is
    signal sresetn: std_ulogic;
    signal pulseout: std_ulogic;
    signal proctodi: std_ulogic;
    signal reg1: std_ulogic;
    signal reg2: std_ulogic;
    signal led_local: std_ulogic_vector(3 downto 0);
begin
    led <= led_local;
    proctodi <= led_local(0) or (reg1 and pulseout);
    sr: entity work.sr(arc)
    port map(
               clk => clk,
               do => led_local,
               sresetn => sresetn,
               di => proctodi,
               shift => pulseout
            );

    tim: entity work.timer(arc)
    generic map (
                    freq => freq,
                    timeout => timeout
                )
    port map (
                    clk => clk,
                    sresetn => sresetn,
                    pulse => pulseout
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
               reg1 <= '1';
           elsif pulseout = '1' then
               reg1 <= '0';
           end if;
       end if;
   end process;
end architecture arc;




