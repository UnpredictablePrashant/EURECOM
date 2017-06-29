
library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity lb is
	generic(
		freq:    positive range 1 to 1000;
		timeout: positive range 1 to 1000000
	);
	port(
		clk:      in  std_ulogic;
		areset:  in  std_ulogic;
		led:    out std_ulogic_vector(3 downto 0)
	);
end entity lb;


architecture arc of timer is
	signal reg: std_ulogic_vector(2 downto 0);
	signal sresetn_s: std_ulogic;
	signal led0: std_ulogic;
	signal di_s: std_ulogic;
	signal shift_s: std_ulogic;

	component timer is
		port(
			clk:      in  std_ulogic;
			sresetn:  in  std_ulogic;
			pulse:    out std_ulogic
		);
	end component;

	component sr is 
		port (clk: in std_ulogic;
		      sresetn: in std_ulogic; 
		      shift: in std_ulogic; 	
		      di: in std_ulogic; 	
		      do: out std_ulogic_vector(3 downto 0)
		);
	END component;

begin
	C1: timer  port map(clk, sresetn_s, shift_s);
	C2: sr  port map(clk, sresetn_s, shift_s, di_s, led);	

	process(areset, clk)
	begin
		if(areset=1) then 
			di_s <= '1';
			if rising_edge(clk) then
				led0 <= led(0);
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			reg(0) <= reg(1);
			reg(1) <= not(areset);
		end if;
	end process;

end architecture arc;
