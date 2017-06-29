LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
--use ieee.numeric_std.all;

ENTITY lb IS
	generic (freq: positive range 1 to 1000 := 100;
		timeout: positive range 1 to 1000000 := 500000);
	PORT (clk: IN std_ulogic;
		areset: IN std_ulogic;
		led: OUT std_ulogic_vector(3 downto 0));
END lb;

ARCHITECTURE arc OF lb IS
signal rst_int_sig : std_ulogic_vector(1 downto 0);
signal sresetn: std_ulogic;
signal pulse: std_ulogic;
signal dlp: std_ulogic; --data looped back
signal do : std_ulogic_vector(3 downto 0);
signal sel : std_ulogic;

BEGIN
sresetn <= rst_int_sig(0);
led <= do;

sr: entity work.sr(arc) 
	port map(clk => clk, sresetn => sresetn, shift => pulse, di => dlp, do => do);

timer: entity work.timer(arc)
	generic map(freq => freq, timeout => timeout)
	PORT map(clk => clk, sresetn => sresetn, pulse => pulse);

sresetn_gen: process(clk)
	begin
		if rising_edge(clk) then
				rst_int_sig <= not areset & rst_int_sig(1);
		end if;
	end process;

dlp_gen: process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				sel <= '0';
			elsif pulse = '1' then
				sel <= '1';
			end if;
		end if;
	end process;

with sel select dlp <=
	'1' when '0',
	do(0) when others;

END arc;