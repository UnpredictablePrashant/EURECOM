entity accumulator is 
    port (
        CLK: in bit;
        A_RST: in bit;
        A: in integer;
        B: in integer;
        S: in bit;
	Q: out integer
    );
end entity accumulator;

architecture rtl of accumulator is
    signal C: integer;
    signal D: integer;
    signal X: integer;
begin
    X<=Q;
    P1: process (S,X,B) -- multiplexer
    begin
        if (S='1') then
            C<=B;
        else
            C<=X;
        end if;
    end process P1;

    P2: process(A,C) -- accumulator
    begin
        D<=A+C;
    end process P2;

    P3: process (CLK, A_RST,D) -- register
    begin
        if (A_RST='1') then
            Q<=0;
        elsif (CLK='1') and CLK'event then 
            Q<=D;
        end if;
    end process P3; 
end architecture rtl;   
