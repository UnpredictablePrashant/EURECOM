--has to be compiled with vhdl -2008 because the outputs are read


--entity declaration
ENTITY accumulator is
	PORT (
		A: in integer;
		B: in integer;		
		Q: out integer;
		S: in bit;
		A_RST: in bit;
		clk: in bit	
	);
end entity accumulator;

--architecture declaration
architecture rules of accumulator is
	signal SELECTED,SUM,Q_local:integer;
begin
	--multiplexor, this is combinatorial, so all signals in sensitivity list
	p1: process(B,S,Q_local)
		begin
			if (S='0') then
				SELECTED <=Q_local;
			elsif (S='1') then
				SELECTED <=B;
			end if;
	end process p1;
	
	-- adder
	p2: process(A,SELECTED)
		begin
			SUM<=A+SELECTED;
	end process p2;
		
	-- register, beware of the delay
	p3:process(clk,A_RST)
		begin
			
			if A_RST='1' then
				Q_local<=0;
			else 
				if clk='1' and clk'event then
					Q_local<=SUM;
				end if;
			end if;
	end process p3;
	Q<=Q_local;
				

end architecture rules;
