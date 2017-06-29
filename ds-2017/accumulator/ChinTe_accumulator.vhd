entity accumulator is
  port(
    clk  : in  bit;
    a_rst: in  bit;
    s:     in  bit;
    a:     in  integer;
    b:     in  integer;
    q:     BUFFER integer
  );
end entity accumulator;



architecture rtl of accumulator is
  signal mux_out: integer;
  signal add_out: integer;
  signal feed_back: integer;
 
begin
  mux: process(s,b,q)
  begin
     if S= '1' then
      mux_out <= b;
     else
      mux_out <= feed_back;
     end if;
  end process mux;

  add: process(a,mux_out)
  
  begin
    add_out <= A + mux_out;
  end process add;

  rst: process(a_rst,clk)
  begin
    if a_rst='1' then
     q<=0;
     feed_back<=0;
    elsif clk='1' and clk'event then
     q<=add_out;
     feed_back<=add_out;
    end if;
  end process rst;

end architecture rtl;


