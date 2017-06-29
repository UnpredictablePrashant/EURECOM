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
	signal mem_do,do:    std_ulogic_vector(39 downto 0);
	signal checksum :   std_ulogic;

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

	DataDisplay: process(do, sw, pe, b, checksum) -- display the datas to the LEDs
	begin
		if sw(3) = '1' then
			led(0) <= checksum;
			led(1) <= b;
			led(2) <= sw(0);
			led(3) <= pe;
		else
			if sw(0) = '0' then
				--visualize RH values
				case sw(2 downto 1) is
				when "00" => 
					led(3 downto 0) <= mem_do(15 downto 12);
				when "01" =>
					led(3 downto 0) <= mem_do(11 downto 8);
				when "10" => 
					led(3 downto 0) <= mem_do(7 downto 4);
				when "11" => 
					led(3 downto 0) <= mem_do(3 downto 0);
				when others =>  
					led(3 downto 0) <= (others => '0');
				end case;
			else 
			--visualize T values
				case sw(2 downto 1) is
				when "00" => 
					led(3 downto 0) <= mem_do(31 downto 28);
				when "01" => 
					led(3 downto 0) <= mem_do(27 downto 24);
				when "10" => 
					led(3 downto 0) <= mem_do(23 downto 20);
				when "11" => 
					led(3 downto 0) <= mem_do(19 downto 16);
				when others =>  
					led(3 downto 0) <= (others => '0');
				end case;
				end if;
				end if;
	    end process DataDisplay;

   	DoRegister: process(clk) --register to store the value of do by the controller
        begin 
	if(clk' event and clk = '1') then
		if(srstn = '0') then
			mem_do <= (others => '0');
            	else
              		mem_do <= do;
            	end if;
        end if;
        end process DoRegister; 
		
	
	ChecksumDisplay : process(mem_do) -- compute the checksum to check if everything is fine or not
	begin
		if std_ulogic_vector(unsigned(mem_do(39 downto 32)) + unsigned(mem_do(31 downto 24)) + unsigned(mem_do(23 downto 16)) + unsigned(mem_do(15 downto 8))) /= mem_do(7 downto 0) then
			checksum <= '1';
		else
			checksum <= '0';
		end if;
	end process ChecksumDisplay;

end architecture rtl;
