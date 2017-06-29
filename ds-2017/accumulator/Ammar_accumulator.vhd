entity accumulator is
  port(
    clk:   in  bit;
    a_rst: in  bit;
    s:     in  bit;
    a:     in  integer;
    b:     in  integer;
    q:     out integer
  );
end entity accumulator;

architecture rtl of accumulator is
  signal out1: integer;
  signal out2: integer;

begin
  p1: process(s,q,b)
begin
  if (s='1') then
  out1<=b;
  else
  out1<=q;
  end if;
end process p1;
  p2: process(out1,a)
begin
  out2 <= out1+a;
  end process p2;

  p3: process(a_rst,clk)
begin
  if(a_rst= '1') then
  q<=0;
else
if(clk'event and clk='1') then
q<=out2;
end if;
end if;
end process p3;
end architecture rtl;

