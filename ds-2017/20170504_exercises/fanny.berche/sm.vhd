library IEEE;
use IEEE.std_logic_1164.all;

entity sm is

    port(
            clk : in std_ulogic;
            sresetn : in std_ulogic;
            go : in std_ulogic;
            stp : in std_ulogic;
            spin : in std_ulogic;
            up : out std_ulogic
        );

end sm;

architecture arc of sm is
    type ST is (RUN, IDLE, HALT);
    signal STATE, NEXT_STATE: ST;

begin

    RESET_PROCESS : process(clk, sresetn)
    begin
        if sresetn = '0' then
            STATE <= IDLE;
        elsif clk'event and clk = '1' then
            STATE <= NEXT_STATE;
        end if;
    end process RESET_PROCESS;

    OUTPUT_PROCESS : process(STATE)
    begin
        case STATE is
            when RUN => up <= '1';
            when IDLE => up <= '0';
            when HALT => up <= '0';
            when others => up <= '0';
        end case;
    end process OUTPUT_PROCESS;

    CHANGE_STATE_PROCESS : process(STATE, go, spin, stp)
    begin
        case STATE is
            when IDLE => if go = '0' then
                            NEXT_STATE <= IDLE;
                        else
                            NEXT_STATE <= RUN;
                        end if;
        when RUN => if stp = '0' then
                        NEXT_STATE <= RUN;
                    else 
                        NEXT_STATE <= HALT;
                    end if;
        when HALT => if go = '1' and spin = '0' then
                        NEXT_STATE <= RUN;
                    elsif go = '0' and spin = '0' then
                        NEXT_STATE <= IDLE;
                    elsif spin <= '1' then
                        NEXT_STATE <= HALT;
                    end if;
        end case;
    end process CHANGE_STATE_PROCESS;

end architecture arc;
