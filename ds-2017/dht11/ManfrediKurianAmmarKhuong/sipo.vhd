-- SIPO (Serial-In Parallel-Out) Shift Register

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types

entity sipo is
	port(
	    clk:	in  std_ulogic;
	    srstn:	in  std_ulogic;
	    shift:	in  std_ulogic;
	    D_in:	in  std_ulogic;
	    pe:		in  std_ulogic;
	    do:	out std_ulogic_vector(39 downto 0) := (others => '0')
	);
end entity sipo;

architecture arc of sipo is
	signal reg: std_ulogic_vector(39 downto 0);
	signal done: std_ulogic;
begin
	--sipo_out_8bit <= reg(7 downto 0); 
	--sipo_out_32bit <= reg(39 downto 8);

	process(clk)
		variable bit_count: natural := 0;
	begin
		--done <= '0';		-- by default, no data ready yet.
		if rising_edge(clk) then
			if ((srstn = '0') or (pe = '1')) then -- synchronous, active low, reset
				reg <= (others => '0'); -- aggregate notation
				bit_count := 0;
				done <= '1';
			elsif shift = '1'  then
				reg <= reg(38 downto 0) & D_in; -- should be shift LEFT
				bit_count := bit_count + 1;
			end if;

			if bit_count = 40 then
				bit_count := 0;
				done <= '1';
			else
				done <= '0';	-- shifting, output data not ready
			end if;
            
            if (done = '1') then
                do <= reg;
                -- else: the old value will be kept on data out (NOT erase it to 0)
            end if;
		end if;
	end process;
end architecture arc;
