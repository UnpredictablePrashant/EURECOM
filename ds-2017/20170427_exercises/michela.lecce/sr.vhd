LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


ENTITY sr IS 
	PORT (clk: in std_ulogic;
	      sresetn: in std_ulogic; 
	      shift: in std_ulogic; 	
              di: in std_ulogic; 	
              do: out std_ulogic_vector(3 downto 0));
END sr;

ARCHITECTURE arc OF sr IS
	signal reg: std_ulogic_vector(3 downto 0);

	BEGIN 
	process (clk)
    	begin
	    if (clk' event and clk='1') then
	        if (sresetn = '0') then 
	            reg <= (others => '0');
	        elsif (shift = '1') then
    		    reg <= di & reg(3 downto 1);
	        end if;
	    end if;
	end process;
    
        do <= reg;
    
END arc;

