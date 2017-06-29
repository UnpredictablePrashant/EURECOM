library ieee;
use ieee.std_logic_1164.all;

entity sm is
	port(
  		clk       : in      std_ulogic;
  		sresetn   : in      std_ulogic;
      go        : in      std_ulogic;
      stp       : in      std_ulogic;
      spin      : in      std_ulogic;
  		up        : out     std_ulogic
  	 );
end entity sm;

architecture arc of sm is
  type state_type is (IDLE,RUN,HALT);
  signal PS,NS     :  state_type;
begin

  ns_updater: process(clk)
  begin
    if(clk'event and clk = '1') then
	     if(sresetn = '0') then
         PS <= IDLE;
       else
         PS <= NS;
       end if;
    end if;
   end process;

   comb_out: process(PS,go,stp,spin)
   begin
     up <= '0';
     case PS is
       when IDLE =>
          if (go = '0') then
            NS <= IDLE;
          else
            NS <= RUN;
          end if;
       when RUN =>
          if (stp = '0') then
            NS <= RUN;
            up <= '1';
          else
            NS <= HALT;
            up <= '1';
          end if;
       when HALT =>
          if (spin = '1') then
            NS <= HALT;
          elsif (go = '1' and spin = '0') then
            NS <= RUN;
          else
            NS <= IDLE;
          end if;
       when OTHERS =>
            NS <= IDLE;
      end case;
    end process;
end architecture arc;
