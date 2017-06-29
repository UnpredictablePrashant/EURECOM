library ieee;
use ieee.std_logic_1164.all;

entity sm is
  port(
    clk  :   in  std_ulogic;
    sresetn: in  std_ulogic;
    go:      in std_ulogic;     
    stp:     in  std_ulogic;
    spin:    in  std_ulogic;
    up:     out  std_ulogic
);
end entity sm;

architecture arc of sm is
   TYPE STATE_TYPE IS (IDLE, RUN, HALT);
   SIGNAL state   : STATE_TYPE;
begin
 up <= '1' when state = run else '0';

 p3: process(clk)
  begin
   if clk='1' and clk'event then
     if sresetn='1'and state=IDLE and up='0' then
        if go='0' then 
		state <=IDLE;
	elsif go='1' then
		state <=RUN;
	end if;
     elsif sresetn='1'and state=RUN and up='1' then
	 if stp='0' then
                state <=RUN;
         elsif stp='1' then
                state <=HALT;
         end if;
     elsif sresetn='1'and state=HALT and up='0' then
         if spin='1' then
                state <=HALT;
         elsif spin='0' then
		if go='1' then
                    state <=HALT;
		elsif go='0' then
	            state <=IDLE;
		end if;
         end if;

     elsif sresetn='0'then
        state <= IDLE;
     end if;
   end if;
  end process p3;

end architecture arc;






