-- DTH11 controller wrapper, standalone version, top level

--library unisim;
--use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use work.dht11_pkg.all;

entity dht11_sa_sim is
end entity dht11_sa_sim;

architecture rtl of dht11_sa_sim is

	--variable freq:    positive range 1 to 1000; -- Clock frequency (MHz)
	signal 	clk:      std_ulogic;
	signal 	rst:      std_ulogic;                    -- Active high synchronous reset
	signal 	btn:      std_ulogic;
	signal 	start:      std_ulogic;
	signal 	count:  	natural;
	signal 	timer_rst:      std_ulogic;
	signal 	sw:       std_ulogic_vector(3 downto 0); -- Slide switches
	signal 	data:     std_logic;
	signal 	led:      std_ulogic_vector(3 downto 0);  -- LEDs
	signal data_in:   std_ulogic;
	signal fall:   std_ulogic;
	signal rise:   std_ulogic;
	signal data_drv:  std_ulogic;
	--signal data_drvn: std_ulogic;

begin

	u0: entity work.dht11_sa(rtl)
	generic map(
		freq => 125
	)
	port map(
		clk      => clk,
		rst      => rst,
		btn      => btn,
		sw       => sw,
		data_in  => data_in,
		data_drv => data_drv,
		led      => led
	);

    -- clock generator
    process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    process
    begin
        wait until timer_rst = '1' for 1 us;

        count <= count + 1;

        if (timer_rst = '1') then
            wait until rising_edge(clk);
            count <= 0;
        end if;
    end process;

    -- 01011 
    process
    begin
        wait until count = dht11_reset_to_start_min; --1sec
        btn <= '1';
        wait until count = dht11_start_duration_min +1000 ; --20ms
        wait until count = dht11_start_to_ack_min; --20us

        wait until rising_edge(clk);
        data_in <= '0';
        wait until rising_edge(clk);
        --fall <= '0';

        wait for dht11_ack_duration_t; --80us


        wait until rising_edge(clk);
        data_in <= '1';
        wait until rising_edge(clk);
        --rise <= '0';
        wait for dht11_ack_to_bit_t; --80

        wait until rising_edge(clk);
        data_in <= '0';
        wait until rising_edge(clk);
        --fall <= '0';
        wait for dht11_bit_duration_t; --50us


        wait until rising_edge(clk);
        data_in <= '1';
        wait until rising_edge(clk);
       -- rise <= '0';
        wait for dht11_bit0_to_next_min_t ;--26 us

        -- data starts here   
        for i in 39 downto 9 loop

                wait until rising_edge(clk);
                data_in <= '0';
                wait until rising_edge(clk);
                --fall <= '0';
                wait for dht11_bit_duration_t; --50us
                wait until rising_edge(clk);
                data_in <= '1';
                wait until rising_edge(clk);
                --rise <= '0';
                wait for dht11_bit0_to_next_min_t ; --26 us

        end loop; -- 

        wait until rising_edge(clk);
        data_in <= '0';
        wait until rising_edge(clk);
        --fall <= '0';
        wait for dht11_bit_duration_t;

        wait until rising_edge(clk);
        data_in <= '1';
        wait until rising_edge(clk);
        --rise <= '0';
        wait for dht11_bit1_to_next_t ;

        -- checksum starts here
        for i in 7 downto 1 loop

                wait until rising_edge(clk);
                data_in <= '0';
                wait until rising_edge(clk);
                --fall <= '0';
                wait for dht11_bit_duration_t; --50us


                wait until rising_edge(clk);
                data_in <= '1';
                wait until rising_edge(clk);
                --rise <= '0';
                wait for dht11_bit0_to_next_min_t ; --26 us
        end loop;

        wait until rising_edge(clk);
        data_in <= '0';
        wait until rising_edge(clk);
        --fall <= '0';
        wait for dht11_bit_duration_t;

        wait until rising_edge(clk);
        data_in <= '1';
        wait until rising_edge(clk);
        --rise <= '0';
        wait for dht11_bit1_to_next_t ;


	end process;
end architecture rtl;
