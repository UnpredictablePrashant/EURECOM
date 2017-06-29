library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
    port (Clk, S, A_Rst: in bit;
          A, B: in integer;
          Q: out integer);
end entity;

architecture beh of accumulator is
    signal tmp: integer;
    begin
        process(Clk, A_Rst)
        begin
	    if(A_Rst='1') then
		tmp<=0;
	    elsif(clk'event and clk='1') then
		if(S='1') then
		    tmp<=A+B;
	        else
		    tmp<=tmp+A;
		end if;
	    end if;
	end process;
    Q<=tmp;
end beh;
