library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sm is
  port(
    clk:  in  std_ulogic;
    sresetn:  in  std_ulogic;
    go: in std_ulogic;
    stp: in std_ulogic;
    spin: in std_ulogic;
    up: out std_ulogic
  );
end entity sm;

architecture arc of sm is
    TYPE state_type IS (IDLE, RUN, HALT);  -- Define the states
    SIGNAL currstate, nextstate : state_type;	
begin

PROCESS (nextstate)
  BEGIN
	currstate <= nextstate;
END process;


PROCESS (clk) 
  BEGIN 
    if rising_edge(clk) then  
	if (sresetn = '0') then
           nextstate <= IDLE;
	else
		CASE currstate IS

			WHEN IDLE => 
				up <= '0';
				IF go = '0' THEN 
					nextstate <= IDLE;
				ELSE 
					nextstate <= RUN;
				end if;
			WHEN RUN => 
				up <= '1';
				IF stp = '0' THEN 
					nextstate <= RUN;
				ELSE 
					nextstate <= HALT;
				end if;
			 WHEN HALT => 
				up <= '0';
				IF spin = '1' THEN 
					nextstate <= HALT;
				ELSIF spin = '0' and go = '1' THEN 
					nextstate <= RUN;
				ELSE
					nextstate <= IDLE;
				end if;
			WHEN others =>
				nextstate <= IDLE;
		END CASE;
	end if;
    end if;
  END process;

end architecture arc;

