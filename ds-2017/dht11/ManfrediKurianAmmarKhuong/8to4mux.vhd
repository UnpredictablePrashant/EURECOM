library IEEE; 
use ieee.numeric_std.all;
--use ieee.std_ulogic.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;


-- Declare inputs and outputs
entity d_select_mux2 is
  port(
    PE:    in std_ulogic;
    B:     in std_ulogic;
    CE:    in std_ulogic;
    SW:    in std_ulogic_vector(1 downto 0);
    mux_do: in std_ulogic_vector(3 downto 0);
    led:   out std_ulogic_vector(3 downto 0)
  );
end entity d_select_mux2;

architecture arc of d_select_mux2 is 
begin 
    process (PE,B,CE,SW,mux_do)
    begin 
		if SW(1) = '0' then
			led <= PE & SW(0) & B & CE;
		else
			led <= mux_do;
	        end if;
    end process;
end architecture arc;
