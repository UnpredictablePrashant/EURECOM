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
  signal I1: integer;
  signal I2: integer;
  signal q_local: integer;


begin
  p1: process(q_local)   
  begin     
	Q <= q_local;   
  end process p1;

    I1 <= q_local WHEN (S = '0') else B;

  p2: process(a, I1)
    begin
        I2 <= a + I1;
    end process p2;
  p3: process (CLK,A_RST)
    begin
	if clk = '1' then
		q_local <= I2;
	end if;
	if a_rst = '1' then 
		q_local <= 0;
	end if;
	end process p3;
end architecture rtl;
