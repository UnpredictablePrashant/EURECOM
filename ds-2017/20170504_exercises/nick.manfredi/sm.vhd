library IEEE;
--use ieee.numeric_std.all;
use IEEE.std_logic_1164.all;

entity sm is 
    port(
        clk: in std_ulogic;
        sresetn: in std_ulogic;
        go: in std_ulogic;
        stp: in std_ulogic;
        spin: in std_ulogic;
        up: out std_ulogic
    );
end entity sm;

architecture arc of sm is
    type state_type is (IDLE,RUN,HALT); -- enum type with names for SM
    signal ps, ns : state_type; -- 2 internal signals bc 1 proc for state reg
                                -- 1 proc for output
                                --  1 proc for next state
                                -- need 2 internal signals to go between these 3
    signal up_local: std_ulogic; -- 
begin
    up <= '1' when ps = run else '0'; -- this is process, concurrent signal assignment, like process whose sensitivity list has everything in the right hand. this is shorthand, so only state in sensitivity list. 
    -- can do (equivalent)
    -- if state = run then
    --  up= '1';
    -- else
    --  up = '0';
    -- end if;
    sync_proc: process(clk) --process to model state registers. reset is sync, so ONLY clock. don't think - sync reset means sync process sens list has only clcok. Starts with if rising edge clock and ends with end if and nothing outside if statement. Only inside if stmt test the sync reset (only if rising edge of clock). 
    begin 
        if rising_edge(clk) then
            if (sresetn = '0') then 
                ps <= IDLE; -- force syncreset to idle if reset
            elsif (rising_edge(clk)) then
                ps <= ns;
            end if;
        end if;
     end process sync_proc;

    comb_proc: process(ps, go, stp, spin) -- models next state computation. 
        -- this has all input arrows, plus prev state. 
        -- in comb process, outputs must be assigned value at EVERY execution.
        -- to guarantee this, start by assigning current value of state to next state.
        -- by default, next state same as current state.
    begin
        ns <= ps; -- default, dont change state
        case PS is -- case stmt to enumerate 3 possible states. 
            when IDLE => -- for each case, test inputs to see if u most change states.
                if go = '1' then
                    ns <= RUN;
                end if;
            when RUN =>
                if stp = '1' then
                    ns <= HALT;
                end if;

            when HALT =>
                if spin = '0' then
                    if go = '1' then
                        ns <= RUN;
                    else
                        ns <= IDLE;
                    end if;
                end if;
        end case;
    end process comb_proc;

end architecture arc;
