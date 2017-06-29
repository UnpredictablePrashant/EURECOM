entity accumulator is
    port( clk: in bit;
        A_RST: in bit;
        s: in bit;
        A: in integer;
        B: in integer;
        Q: out integer
    );
end entity accumulator;
architecture rtl of accumulator is
signal D: integer;
signal X: integer;
signal Y: integer;
begin    
   
    P1: process(D,B,s)
    begin
        if (s = '0') then
            X<=D;
        else
            X<=B;
        end if;
    end process;

    P2: process(X,A)
    begin
        Y<=X+A;
    end process;

    P3: process(clk, a_rst)
    begin
        if(a_rst='1') then
            D<=0;
            Q<=0;
        elsif(clk='1') and clk'event then
            D<=Y;
            Q<=Y;
        end if;
    end process;
end architecture rtl;




