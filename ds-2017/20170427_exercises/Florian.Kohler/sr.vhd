LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sr IS
	PORT (	clk, sresetn, shift, di : IN std_ulogic; 
		do : OUT std_ulogic_vector(3 downto 0));
END sr;


ARCHITECTURE arc OF sr Is
	SIGNAL reg : std_ulogic_vector(3 downto 0);
BEGIN
	do <= reg;
	bra : PROCESS(clk)
	BEGIN
		
		IF clk='1' and clk'event THEN
			IF sresetn='0' THEN
				reg(0) <= '0';
				reg(1) <= '0';
				reg(2) <= '0';
				reg(3) <= '0';
			
			ELSIF shift='1' THEN
				reg <= di & reg(3 downto 1); -- mine was reg <= reg srl 1;
			END IF;
			
		END IF;
	END PROCESS bra;
END arc;
