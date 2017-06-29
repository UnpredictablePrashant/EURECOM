LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY accumulator IS
	PORT (A,B: IN integer;
		Q: OUT integer;
 	      S, clk, A_Rst: IN bit);
END accumulator;

ARCHITECTURE bhv OF accumulator IS
SIGNAL outMux, outAdd, outReg: integer;
Begin

with S select outMux <=
	B when '1',
	outReg when others;

outAdd <= outMux + A;

process(Clk, A_Rst)
begin
	if A_Rst='1' then
		outReg <= 0;
	elsif Clk = '1' and clk'event then
		outReg<= outAdd;
	end if;
end process;

Q <= outReg;
end bhv;
