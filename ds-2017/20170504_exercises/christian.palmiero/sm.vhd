library ieee;
use ieee.std_logic_1164.all;

entity sm is
    port(clk     : in std_ulogic;
         sresetn : in std_ulogic;
         go      : in std_ulogic;
         stp     : in std_ulogic;
         spin   : in std_ulogic;
         up      : out std_ulogic);
end entity sm;

architecture arc of sm is

type statetype is (IDLE, RUN, HALT);
signal current_state, next_state: statetype;

begin

    process(clk)
    begin
        if clk'event and clk='1' then
            if sresetn='0' then
                current_state<=IDLE;
            else
                current_state<=next_state;
            end if;
        end if;
    end process;

    process(go, stp, spin, current_state)
    begin
        next_state<=current_state;
        case current_state is
            when IDLE => if go='0' then
                             next_state<=IDLE;
                         elsif go='1' then
                             next_state<=RUN;
                         end if;

            when RUN =>  if stp='0' then
                             next_state<=RUN;
                         elsif stp='1' then
                             next_state<=HALT;
                         end if;

            when HALT => if spin='1' then
                             next_state<=HALT;
                         elsif spin='0' and go='1' then
                             next_state<=RUN;
                         elsif spin='0' and go='0' then
                             next_state<=IDLE;
                         end if;
            when others => next_state <= IDLE;
        end case;
    end process;

    process(current_state)
    begin
        case current_state is
            when IDLE => up <= '0';
            when RUN  => up <= '1';
            when HALT => up <= '0';
        end case;
    end process;

end architecture arc;
