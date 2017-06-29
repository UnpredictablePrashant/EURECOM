entity accumulator is
  port(
    clk:    in  bit;
    a_rst:  in	bit;
    s:	    in	bit;
    a:	    in	integer;
    b:	    in	integer;
    q:	    out	integer
);
end entity accumulator;

architecture rtl of accumulator is
  signal c: integer;
  signal d: integer;
  signal q_local: integer;

begin
  multiplexer: process(b, q_local, s)
    variable c_local: integer;
  begin
    if (s = '1') then
     c_local := b;
    else c_local := q_local;
    end if;

    c <= c_local;

  end process multiplexer;
  
  adder: process(a,c)
  begin
    d <= a + c;
  end process adder;
  
  P3: process(clk, a_rst)
  begin
    if (a_rst = '1') then
      q_local <= 0;
    elsif clk'event and (clk = '1') then
      q_local <= d;
    end if;
  end process P3;

  P4: process(q_local)
  begin
    q <= q_local;
  end process P4;
end architecture rtl;
