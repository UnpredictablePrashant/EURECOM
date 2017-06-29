entity accumulator is
    port(
        CLK:    in   bit;
        B:      in   integer;
        S:      in   bit;
        A:      in   integer;
        A_RST:  in   bit;
        Q:      out  integer
    );
end accumulator;

architecture arc of accumulator is
    signal D,C,Q_local: integer;
begin
    P1: process(A,C)
    begin
        D <= A+C;
    end process P1;

    P2: process(CLK, A_RST)
        variable a: integer;
    begin
        if CLK'event and CLK = '1' then
            a := D;
        end if;
        if A_RST = '1' then
            a := 0;
        end if;
        Q_local <= a;
    end process P2;

    P3: process(S, B, Q_local)
    begin
        if S = '1' then
            C <= B;
        else
            C <= Q_local;
        end if;
    end process P3;

    Q <= Q_local;

end arc;
