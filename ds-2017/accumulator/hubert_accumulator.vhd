entity accumulator is 
  port (
    clk:  in  bit;
    A_RST:  in  bit;
    A:  in  integer;
    B:  in  integer;
    S:  in  bit;
    Q:  out  integer
  );
end entity accumulator;

architecture rtl of accumulator is 
  signal c,d,data: integer; 
begin 
  process(B,data,S)
  begin 
    if S = '1' then
      c <= B;
    else 
      c <= data;
    end if;
  end process;

  process(A,c)
  begin 
    d <= A + c;
  end process;

  process(clk,A_RST) 
  begin 
    if A_RST = '1' then 
      data <= 0;
    elsif clk'event and clk='1' then
      data <= d;
    end if;
  end process;
  Q <= data;
end architecture rtl;
