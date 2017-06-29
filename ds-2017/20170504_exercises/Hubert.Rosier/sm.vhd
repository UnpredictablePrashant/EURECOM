library ieee;
use ieee.std_logic_1164.all;

entity sm is
port (
       clk:  in  std_ulogic;
       sresetn:  in  std_ulogic;
       go:  in  std_ulogic;
       stp:  in  std_ulogic;
       spin:  in  std_ulogic;
       up : out std_ulogic
     );
end entity sm;

architecture arc of sm is 
  type STATE is (IDLE,RUN,HALT);
  signal current_state : STATE;

begin
  process (clk)
  begin 
    if rising_edge(clk) then
      if sresetn = '0' then
        current_state <= IDLE;
      else 
        case current_state is
          when IDLE =>
            if go = '0' then
              current_state <= IDLE;
            else
              current_state <= RUN;
            end if;
          when RUN =>
            if stp = '0' then
              current_state <= RUN;
            else
              current_state <= HALT;
            end if;
          when HALT => 
            if spin = '1' then
              current_state <= HALT;
            elsif go = '1' then
              current_state <= RUN;
            else 
              current_state <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;

  process (current_state)
  begin
    case current_state is 
      when IDLE => up <= '0';
      when RUN => up <= '1';
      when HALT => up <= '0';
    end case;
  end process;

end arc;
