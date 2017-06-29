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
    P1: process
    begin
        D <= A+C;
        wait on A, C;
    end process P1;
    P2: process
        variable a: integer;
    begin
        if CLK'event and CLK = '1' then
            a := D;
        end if;
        if A_RST = '1' then
            a := 0;
        end if;
        Q_local <= a;
        wait on CLK, A_RST;
    end process P2;
    P3: process
    begin
        if S = '1' then
            C <= B;
        else
            C <= Q_local;
        end if;
        wait on S, B, Q_local;
    end process P3;
    Q <= Q_local;
end arc;
