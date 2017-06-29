-- vim: set textwidth=0:

--use std.env.all; -- to use --stop and finish

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

-- Simulation environments are frequently back boxes
entity timer_sim is
end entity timer_sim;

architecture sim of timer_sim is

    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    signal timer_rst: std_ulogic;

    constant freq:           positive range 1 to 1000    := 10;
    --constant timeout:        positive range 1 to 1000000 := 50; --pulse every 1 microseconds. Can change after discussing FSM.
    constant period:         real := 1000.0 / real(freq); -- ns
    signal count:    natural; --range 0 to timeout - 1;

begin

    -- entity instantiation of the Design Under Test
    dut: entity work.timer(arc)
        generic map(
            freq    => freq --,
            --timeout => timeout
        )
        port map(
            clk     => clk,
            sresetn => sresetn,
            timer_rst => timer_rst,
            count   => count
        );

    -- clock generator
    process
    begin
        clk <= '0';
        wait for (period / 2.0) * 1 ns;
        clk <= '1';
        wait for (period / 2.0) * 1 ns;
    end process;

    process
    begin
        timer_rst <= '1'; -- timer reset HAPPENING
        sresetn <= '0'; -- reset HAPPENING
        for i in 1 to 50 loop -- wait 50 clock periods
            wait until rising_edge(clk);
        end loop;
        
        timer_rst <= '1'; -- timer reset HAPPENING
        sresetn <= '1'; -- reset NOT happening
        for i in 1 to 50 loop -- wait 50 clock periods
            wait until rising_edge(clk);
        end loop;
        
        timer_rst <= '0'; -- timer reset NOT happening
        sresetn <= '0'; -- reset HAPPENING
        for i in 1 to 50 loop -- wait 50 clock periods
            wait until rising_edge(clk);
        end loop;
        
        timer_rst <= '0'; -- timer reset NOT happening
        sresetn <= '1'; -- reset NOT happening
        for i in 1 to 50 loop -- wait 50 clock periods
            wait until rising_edge(clk); --and pulse = '1';
        end loop;
        
        --stop; -- end simulation
    end process;

end architecture sim;

