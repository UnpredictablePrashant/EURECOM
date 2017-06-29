-- vim: set textwidth=0:

--use std.env.all; -- to use --stop and finish

library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types
use work.dht11_pkg.all;

-- Simulation environments are frequently back boxes
entity fsm_sim is
end entity fsm_sim;

architecture sim of fsm_sim is

       signal clk:           std_ulogic;
       signal srstn:         std_ulogic;
       signal count:         natural:=0;
       signal start:         std_ulogic := '0';
       signal rise:          std_ulogic := '0';
       signal fall:          std_ulogic := '0';
       signal shift:         std_ulogic;
       signal dout_sipo:     std_ulogic;
       signal b:             std_ulogic := '0';
       signal pe:            std_ulogic := '0';
       signal data_drv:      std_ulogic;
       signal timer_rst:     std_ulogic;

begin

    -- entity instantiation of the Design Under Test
    dut: entity work.fsm(arc)
        port map(
            clk     => clk,
            srstn => srstn,
            count => count,
            start => start,
            rise => rise,
            fall => fall,
            shift => shift,
            dout_sipo => dout_sipo,
            b => b,
            pe => pe,
            data_drv => data_drv,
            timer_rst => timer_rst
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
        start <= '1';
        wait until count = dht11_start_duration_min +1000 ; --20ms
        wait until count = dht11_start_to_ack_min; --20us
        
        wait until rising_edge(clk);
        fall <= '1';
        wait until rising_edge(clk);
        fall <= '0';
        
        wait for dht11_ack_duration_t; --80us
     
        
        wait until rising_edge(clk);
        rise <= '1';
        wait until rising_edge(clk);
        rise <= '0';
        wait for dht11_ack_to_bit_t; --80

        wait until rising_edge(clk);
        fall <= '1';
        wait until rising_edge(clk);
        fall <= '0';
        wait for dht11_bit_duration_t; --50us
        
        
        wait until rising_edge(clk);
        rise <= '1';
        wait until rising_edge(clk);
        rise <= '0';
        wait for dht11_bit0_to_next_min_t ;--26 us
       
        
        wait until rising_edge(clk);
        fall <= '1';
        wait until rising_edge(clk);
        fall <= '0';
        wait for dht11_bit_duration_t; --50us
        
        
        wait until rising_edge(clk);
        rise <= '1';
        wait until rising_edge(clk);
        rise <= '0';
        wait for dht11_bit1_to_next_t ; --70us

        wait until rising_edge(clk);
        fall <= '1';
        wait until rising_edge(clk);
        fall <= '0';
        wait for dht11_bit_duration_t;
        
        wait until rising_edge(clk);
        rise <= '1';
        wait until rising_edge(clk);
        rise <= '0';
        wait for dht11_bit0_to_next_min_t ;

        wait until rising_edge(clk);
        fall <= '1';
        wait until rising_edge(clk);
        fall <= '0';
        wait for dht11_bit_duration_t;
        
        wait until rising_edge(clk);
        rise <= '1';
        wait until rising_edge(clk);
        rise <= '0';
        wait for dht11_bit1_to_next_t ;
 
        wait until rising_edge(clk);
        fall <= '1';
        wait until rising_edge(clk);
        fall <= '0';
        wait for dht11_bit_duration_t;
        
        wait until rising_edge(clk);
        rise <= '1';
        wait until rising_edge(clk);
        rise <= '0';
        wait for dht11_bit1_to_next_t ;
    end process;

end architecture sim;

