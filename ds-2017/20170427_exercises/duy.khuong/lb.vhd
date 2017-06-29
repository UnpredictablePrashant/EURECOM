-- vim: set textwidth=0:

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity lb is
	generic(
		freq:    positive range 1 to 1000;
		timeout: positive range 1 to 1000000
	);
	port(
		clk:		in  std_ulogic;
		areset:		in  std_ulogic;
		led:		out std_ulogic_vector(3 downto 0)
	);
end entity lb;

architecture arc of lb is
	signal cnt1: natural range 0 to freq - 1;
	signal cnt2: natural range 0 to timeout - 1;
	signal tick: std_ulogic;
	signal reg: std_ulogic_vector(3 downto 0);
	signal sresetn: std_ulogic;
	signal rst: std_ulogic_vector(3 downto 0);
	signal rst2: std_ulogic_vector(3 downto 0);
	signal shift: std_ulogic;
begin
	led <= reg;

	-- Inverter and a 2-stages shift register
	process(clk, areset)
	begin
	    if (areset = '1') then
		rst <= '0'
	    else
		rst <= '1'
	    end if;
	end process;
	    
	process(clk, rst)
	begin
	    if rising_edge(clk) then
		rst2 <= '0' & rst(3 downto 1);
	    end if;
	end process;

	process(clk, rst2)
	begin
	    if rising_edge(clk) then
		sresetn <= '0' & rst2(3 downto 1);
	    end if;
	end process;

	process(clk, shift)
        begin
                if rising_edge(clk) then
                        if sresetn = '0' then -- synchronous, active low, reset
                                reg <= (others => '0'); -- aggregate notation
                        elsif shift = '1'  then
                                reg <= di & reg(3 downto 1); -- use concatenation and bit-slicing
                        end if;
                end if;
        end process;

	process(clk)
	begin
		if rising_edge(clk) then
			tick <= '0';
			if sresetn = '0' then -- synchronous, active low, reset
				cnt1 <= freq - 1;
			elsif cnt1 = 0 then
				cnt1 <= freq - 1;
				tick <= '1';
			else
				cnt1 <= cnt1 - 1;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			pulse <= '0';
			if sresetn = '0' then -- synchronous, active low, reset
				cnt2 <= timeout - 1;
			elsif tick = '1' then
				if cnt2 = 0 then
					cnt2 <= timeout - 1;
					pulse <= '1';
				else
					cnt2 <= cnt2 - 1;
				end if;
			end if;
		end if;
		shift <= pulse;
	end process;
end architecture arc;
