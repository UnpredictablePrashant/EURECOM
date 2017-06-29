LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY accumulator IS 
	PORT (A,B: IN integer;
	      Q: BUFFER integer;
	      S, Clk, A_Rst: IN bit);
END accumulator;

ARCHITECTURE Beh OF accumulator IS 
	SIGNAL Z, V, T: integer;
	BEGIN 
		MuxProc: PROCESS(S, B, T)
		BEGIN 
			 IF(S = '0') THEN
				Z <= T;
			 ELSE 
				Z <= B;
			 END IF;
		END PROCESS;
			
		AdderProc: PROCESS(A, Z)
		BEGIN
			V <= A + Z;
		END PROCESS;

		RegProc: PROCESS(Clk, A_Rst)
		BEGIN 
			IF(A_Rst = '1') THEN 
				T <= 0; 
			ELSIF(Clk = '1' AND Clk'EVENT) THEN 
				T <= V;
			END IF;
		END PROCESS;

	Q <= T; 
END Beh; 
