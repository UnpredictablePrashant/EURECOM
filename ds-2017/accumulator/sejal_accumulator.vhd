entity accumulator is
  port(
    clk:   in  bit;
    A_RST: in  bit;
    S:     in  bit;
    A:     in  integer;
    B:     in  integer;
    Q:     out integer
  );
end entity accumulator;

architecture rtl of accumulator is
signal D, C, outReg: integer;  
begin
  Q <= outReg;
  p1: process(outReg,B,S)
	begin  
	if(S ='1') then
		C<=B;
    	else
		C<=outReg;
	end if;
  end process p1;

  p2: process(C,A)
  begin
    D<=C+A;
  end process p2;

  p3: process(CLK,A_RST)
  begin
	if(A_RST ='1') then
		outReg<=0;
  	elsif(CLK ='1'and CLK'event) then
		outReg<=D;
	end if;
  end process p3;
end architecture rtl;
