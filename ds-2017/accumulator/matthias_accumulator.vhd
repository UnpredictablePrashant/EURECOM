entity accumulator is
  port(
    CLK:   in  bit;
    ARst: in  bit;
    S:     in  bit;
    A:     in  integer;
    B:     in  integer;
    Q:     buffer integer
  );
end entity accumulator;

architecture rtl of accumulator is
        signal A1,Q1 : integer;

begin
        P1: process(Q,B,S)
        begin
                if(S = '1') then
                        A1 <= B;
                else
                        A1 <= Q;
		end if;
	end process P1;

        P2: process(A1,A)
        begin
                Q1 <= A1 + A;
	end process P2;

        P3: process(ARst,CLK)
        begin
                if(ARst = '1') then
                        Q <= 0;
                elsif(CLK = '1') and clock'event then
                        Q <= Q1;
		end if;
        end process P3;
end architecture rtl;
