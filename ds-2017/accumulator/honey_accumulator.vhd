--declaration of the inputs and outputs(entity)
entity accumulator is
  port(
    CLK:   in  bit;
    A_RST: in  bit;
    S:     in  bit;
    A:     in  integer;
    B:     in  integer;
    Q:     out integer
  );
end entity accumulator;

--architecture
architecture rtl of accumulator is
        -- signal declarations
        signal A1,Q1,a_local : integer;
begin
--beginning the processes
        P1: process(a_local,B,S)
        begin
		
                if(S = '1') then
                        A1 <= B;
                else
                        A1 <= a_local;
		end if;
	end process P1;

        P2: process(A1,A)
        begin
                Q1 <= A1 + A;
	end process P2;

        P3: process(A_RST,CLK)
        begin
                
		if(A_RST = '1') then
                        a_local <= 0;
			Q <= 0;
                elsif(CLK = '1' and CLK'event) then --taking reset into account during the rising edge of a clock
                        a_local <= Q1;
			Q <= Q1;
		end if;
        end process P3;

end architecture rtl;
