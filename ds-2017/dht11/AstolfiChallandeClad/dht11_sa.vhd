-- DTH11 controller wrapper, standalone version

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dht11_sa is
	generic(
		freq:    positive range 1 to 1000 -- Clock frequency (MHz)
	);
	port(
		clk:      in  std_ulogic;
		rst:      in  std_ulogic; -- Active high synchronous reset
		btn:      in  std_ulogic;
		sw:       in  std_ulogic_vector(3 downto 0); -- Slide switches
		data_in:  in  std_ulogic;
		data_drv: out std_ulogic;
		led:      out std_ulogic_vector(3 downto 0) -- LEDs
	);
end entity dht11_sa;

architecture rtl of dht11_sa is

	signal srstn: std_ulogic;
	signal start: std_ulogic;
	signal pe:    std_ulogic;
	signal b:     std_ulogic;
	signal do:    std_ulogic_vector(39 downto 0);
	signal ce:    std_ulogic;

begin

	srstn <= not rst;

	deb: entity work.debouncer(rtl)
	port map(
		clk   => clk,
		srstn => srstn,
		d     => btn,
		q     => open,
    	r     => start,
		f     => open,
		a     => open
	);

	u0: entity work.dht11_ctrl(rtl)
	generic map(
		freq => freq
	)
	port map(
		clk      => clk,
		srstn    => srstn,
		start    => start,
		data_in  => data_in,
		data_drv => data_drv,
		pe       => pe,
		b        => b,
		do       => do
	);

	DISPLAY : process (do, sw, srstn, pe, b, ce)
        variable offset : integer range 0 to 39;
        variable swSwap : unsigned (0 to 2);
        variable temp : unsigned (7 downto 0);
        --variable displayed : std_ulogic_vector(39 downto 0);
	begin
        if srstn = '0' then
            led <= (others => '0');
			ce <= '0';

        else
			temp := unsigned(do(39 downto 32))
		        + unsigned(do(31 downto 24))
		        + unsigned(do(23 downto 16))
		        + unsigned(do(15 downto 8));

		    if (unsigned(do(7 downto 0)) /= temp) then
		        ce <= '1';
		    else
				ce <= '0';
		    end if;

			if sw(3) = '0' then
				swSwap := sw(0)&sw(1)&sw(2);
				offset := to_integer(swSwap)*4;

		        led <= do(offset+3+8 downto offset+8);

		    else
		        led <= (pe, sw(0), b, ce);
		    end if;

		end if;


    end process;


end architecture rtl;
