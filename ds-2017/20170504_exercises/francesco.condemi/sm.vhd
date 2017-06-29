library ieee;
 use ieee.std_logic_1164.all;

 entity sm is   
  port(        clk:    in std_ulogic; 
               sresetn:    in std_ulogic;  
                go:    in std_ulogic;  
                stp:    in std_ulogic; 
                spin:    in std_ulogic; 
                up:    out std_ulogic
       );

end sm;

architecture arc of sm is

TYPE STATE_TYPE IS ( IDLE , RUN, HALT);
SIGNAL STATE :STATE_TYPE;

BEGIN 

TRANSITION : PROCESS(clk)
begin
IF ( CLK' EVENT AND CLK='1') THEN 
 IF SRESETN='0' THEN  STATE<= IDLE;
 ELSE
CASE STATE IS  
    WHEN IDLE => IF UP='0' THEN STATE<= IDLE; ELSE STATE<=RUN;END IF;
    WHEN RUN => IF STP='0' THEN STATE<= RUN; ELSE STATE<=HALT;END IF;
    WHEN HALT => IF SPIN='1' THEN STATE<= HALT; ELSIF GO='1' THEN STATE<= RUN; ELSE STATE<=idle;END IF;
END CASE;
END IF;
END IF;
END PROCESS;

OUTPUT_VALUE : PROCESS(STATE)
BEGIN
UP<='0';
CASE STATE IS 
WHEN IDLE=>
NULL;
WHEN RUN=>
UP<= '1';
WHEN HALT=>
NULL;
END CASE;
END PROCESS;

END ARCHITECTURE arc;



