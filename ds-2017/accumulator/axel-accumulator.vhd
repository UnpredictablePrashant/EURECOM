entity accumulator is
    port(
        clk: in bit;
        a_rst: in bit;
        s: in bit;
        a: in integer;
        b: in integer;
        q: out integer
    );
end entity accumulator;
        
architecture rtl of accumulator is
    signal I1, I2, Q_local: integer;

begin

    -- Multiplexer
    P1: process(S,B,Q_local)
    begin
        if S = '1' then
            I1 <= B;
        else
            I1 <= Q_local;
        end if;
    --- in one line without creating a process: I1 <= Q When (S = '0') else B;it would means that Q,S and B are in the sensitivity list
    end process p1;

    P2: process(I1,A)
    begin
        I2 <= A + I1;
    end process p2;

    --- Asynchronous reset are taken into account in any moment
    --- In comparison synchronous reset are only taken into account in rising edge of clock
    P3: process(CLK,A_RST)
    begin
	if a_rst = '1' then
		Q_local <= 0;
	elsif clk = '1' and clk'event then ---equivalent of all is rising_edge(clock)
		Q_local <= I2;
	end if;
    end process p3;

    Q <= Q_local; -- Equivalent to create one process with Q_local in the sensitivity list
end architecture rtl;	
