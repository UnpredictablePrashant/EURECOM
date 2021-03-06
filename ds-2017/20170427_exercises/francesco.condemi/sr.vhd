library ieee;
 use ieee.std_logic_1164.all;

 entity sr is   
  port(        clk:    in std_ulogic; 
               sresetn:    in std_ulogic;  
                shift:    in std_ulogic;  
                di:    in std_ulogic; 
                do:    out std_ulogic_vector(3 downto 0)
       );

end sr;

architecture arc of sr is
 
 signal r0 :     std_ulogic;
 signal r1  :     std_ulogic;
 signal r2  :     std_ulogic;
 signal r3  :     std_ulogic;
begin
 clock: process(clk)
    begin

        if clk'event and clk = '1' then
          if sresetn = '0' then
          r0<='0';
          r1<='0';
          r2<='0';
          r3<='0';
        elsif shift= '1' then
         r0<= di;
         r1<= r0;
         r2<= r1;
         r3<= r2; 
        end if;
       end if; 
    end process;

r: process(r0,r1,r2,r3)
 begin
do(3)<=r0;
do(2)<=r1;
do(1)<=r2;
do(0)<=r3;
end process;

end architecture arc;
