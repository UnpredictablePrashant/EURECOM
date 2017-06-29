entity accumulator is
  port(
     clk:   in  bit;
     a_rst:  in  bit;
     S:     in  bit;
     A:     in  integer;
     B:     in  integer;
     Q:     out integer
  );
end entity accumulator;

architecture rtl of accumulator is
  signal c, d, r: integer;
begin
  p1: process(S,B,R)
  begin
    if S = '1' then
        c <= B;
    elsif S = '0' then
        c <= r;
    end if;
  end process p1;

  p2: process(A,c)
  begin
    d <= A + c;
  end process p2;

  p3: process(clk, a_rst) 
  begin
    if a_rst = '1' then
        Q <= 0;
	r <= 0;
    elsif clk = '1' and clk'event then
        Q <= d;
	r <= d;
    end if;
  end process p3;
end architecture rtl;


-- NOTE :
-- Don't put the Input in the sensitivity when desinning a rising edge clocked register
-- You only change values when the clock is changing (and you have to specify that it's only on a rising edge of the clock)
-- process(clock)
-- begin
--   if clock='1' and clock'event then
--     Q <= D; 
--   end if;
-- end process

-- FOR THE RESET
-- Put the reset first
