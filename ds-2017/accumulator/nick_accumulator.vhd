-- Declare inputs and outputs
entity accumulator is
  port(
    clk:   in  bit;
    A_Rst: in  bit;
    s:     in  bit;
    a:     in  integer;
    b:     in  integer;
    q:     out integer
  );
end entity accumulator;

architecture rtl of accumulator is -- Specify of what entity it's an architecture
  signal  Q1, Q2, a_local: integer;
begin -- All proceses are below

    P1: process (a_local, s, B) -- The mux
    begin
        if (s = '1') then
            Q1 <= B;
        else
            Q1 <=a_local;
        end if;
    end process P1;

    P2: process (Q1, A) -- The adder
    begin
        Q2 <= Q1 + A;
    end process P2;

    P3: process (CLK, A_Rst) -- Set Q on rising clock edge and reset on ARst
    begin
        if (A_Rst = '1') then
            a_local <= 0;
            Q <= 0;
        elsif (CLK = '1') and CLK'event then
            a_local <= Q2;
            Q <= Q2;
        end if;
    end process P3;

end architecture rtl;
