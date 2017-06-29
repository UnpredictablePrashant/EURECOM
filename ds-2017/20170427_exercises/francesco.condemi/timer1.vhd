library ieee;
 use ieee.std_logic_1164.all;
 
 entity timer is   
generic (freq : positive range 1 to 1000;
         timeout: positive range 1 to 1000000 );
  port(        clk:    inout std_ulogic; 
               sresetn:    in std_ulogic;  

                pulse:    out std_ulogic
       );

end timer;

architecture arc of timer is

 signal tick :     std_ulogic;
 signal counter1 :  positive range 0 to freq-1; 
signal counter2 :  positive range 0 to timeout-1; 
begin 
counter11: process(clk)
begin
 if clk'event and clk = '1' then
   if sresetn = '0' then
   counter1<=freq-1;
   tick<= '0';
   elsif counter1 = 0
   counter1<= freq -1;
   tick<='1';
   else 
   counter1<= counter1 -1;
   tick<= '0';
end if;
end if;
end if;
end process;


counter22: process(clk)
begin
 if clk'event and clk = '1' then
   if sresetn = '0' then
   counter2<=timeout-1;
   pulse<= '0';
    elsif tick='1' then
      if counter2 = 0 then
     counter2<= timeout -1;
      pulse<='1';
      else 
       counter2<= counter2 -1;
       pulse <= '0';
end if;
end if;
end if;
end if;
end process;

end architecture arc;
