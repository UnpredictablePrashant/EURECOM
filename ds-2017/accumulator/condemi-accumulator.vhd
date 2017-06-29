LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


ENTITY accumulator IS 
	PORT (A,B: IN integer;
	      Q: out integer;
	      S, Clk, A_Rst: IN bit);
END accumulator;

ARCHITECTURE Behavior OF accumulator IS 
	SIGNAL outmux, outadder, Temp: integer;
	BEGIN 
		MuxProcess: PROCESS(outmux, B, Temp)
		BEGIN 
			 IF(S = '0') THEN
				outmux <= Temp;
			 ELSE 
				outmux <= B;
			 END IF;
		END PROCESS;
			
		Adderprocess: PROCESS(A, outmux)
		BEGIN
			outadder <= A + outmux;
		END PROCESS;

		flipflop: PROCESS(Clk, A_Rst)
		BEGIN 
			IF(A_Rst = '1') THEN 
				Temp <= 0; 
			ELSIF(Clk = '1' AND Clk'EVENT) THEN 
				Temp <= outadder;
			END IF;
		END PROCESS;

	Q <= temp; 
END Behavior; 
