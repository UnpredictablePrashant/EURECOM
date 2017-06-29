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
  signal sum, outmux, qinside: integer;


begin
  -- additionneur
  p1: process(A,sum,outmux)
  begin
  sum <= outmux+A;
  end process p1;

  --reseter 
  p2: process(clk,a_rst)  
  begin
    IF a_rst = '1'
	THEN q <= 0; 
	     qinside <= 0;
    
    ELSIF clk='1' and clk'event
	THEN q<=sum;
	     qinside<=sum;
    END IF;
  end process p2;

  --multiplexor
  p3: process(s,b,qinside)
  begin
  IF s='1'
	THEN outmux<=B;			

  ELSIF s='0'
	THEN outmux<=qinside;
  END IF;
  end process p3;
end architecture rtl;
