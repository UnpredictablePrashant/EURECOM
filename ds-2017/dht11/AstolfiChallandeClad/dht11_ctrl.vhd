-- DTH11 controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.dht11_pkg.all;

-- Read data (do) format:
-- do(39 downto 24): relative humidity (do(39) = MSB)
-- do(23 downto 8):  temperature (do(23) = MSB)
-- do(7 downto 0):   check-sum = (do(39 downto 32)+do(31 downto 24)+do(23 downto 16)+do(15 downto 8)) mod 256
entity dht11_ctrl is
    generic(
        freq:    positive range 1 to 1000 -- Clock frequency (MHz)
    );
    port(
        clk:      in  std_ulogic;
        srstn:    in  std_ulogic; -- Active low synchronous reset --TODO
        start:    in  std_ulogic; -- active for 1 sec
        data_in:  in  std_ulogic; --TODO
        data_drv: out std_ulogic; --TODO : we use the drive ??
        pe:       out std_ulogic; -- Protocol error
        b:        out std_ulogic; -- Busy
        do:       out std_ulogic_vector(39 downto 0) -- Read data
    );
end entity dht11_ctrl;

architecture rtl of dht11_ctrl is
    type ST is (IDLE, INIT, STORE, ENDTRANSACTION, SET_DO, COUNTER_RESET, STARTING1, STARTING2, SENDING0, SENDING1, RECEIVING0, RECEIVING1);

    signal state : ST := INIT;
    signal stateAfterCounterReset : ST;

    signal timerReset : std_ulogic ; 
    signal count : integer;
    signal pulse : std_ulogic;

    signal endOfRead : std_ulogic;
    signal endOfBitRead : std_ulogic;

    signal startingDHT : std_ulogic := '1';

    signal readStarted: std_ulogic := '0';
    signal started : std_ulogic := '0';

    signal bitRead : std_ulogic;
    signal currentRead : std_ulogic_vector (39 downto 0);
	signal resetSr : std_ulogic;
    
    
begin
    -- TIMER
    timer: entity work.timer(arc)
    generic map(
        freq => freq ,
        timeout => 1
    )
    port map(
        clk      => clk,
        sresetn    => srstn,
        pulse  => pulse
    );

	-- SHIFT REGISTER
    shift_reg: entity work.sr(arc)
      port map (
        clk => clk,
        sresetn => srstn,
        di => bitRead,
    	do => currentRead,
        shift => endOfBitRead,
		resetSr => resetSr
           );

	-- COUNTER
    Counter: process(clk, timerReset)
      begin
        if rising_edge(clk) then
              if srstn = '0' or timerReset = '1' then
                count <= 0;
              elsif pulse = '1' then 
                count <= count + 1;
              end if;
        end if; 
      end process Counter;

    P1 : process (clk)
        constant errorMargin : integer := 10;
        variable index : integer range 0 to 41;
    begin
        if rising_edge(clk) then
            if srstn = '0' then
                state <= INIT;
				-- reset the timer and the shift register
                timerReset <= '1';
				resetSr <= '1';
            else 
				-- by defaukt we don't reset the shift register
				resetSr <= '0';
                case state is
                    when INIT =>
                -- Reset the systems variables
                        timerReset <= '0';
                        data_drv <= '0';
                        started <= '0';
                        pe <= '0';
						resetSr <= '1';
						do <= (others => '0');
                
                -- Until the reset signal is not asserted
                        if (srstn = '1') then
                            b <= '1';  -- busy during 1 second
                            if (count > dht11_reset_to_start_min )
                            then
                                state <= IDLE;
                                b <= '0';
                            end if;

                        end if;
                
                    when IDLE =>
				-- reset the variables 
                        timerReset <= '0';
                        index := 0;
                        readStarted <= '0';

                        endOfRead <= '0';
                        endOfBitRead <= '0';                
                
                        b <= '0';
                        data_drv <= '0';

                        if (start = '1')
                        then -- Go to STARTING1 after having reseted the counter
                            stateAfterCounterReset <= STARTING1;
                            timerReset <= '1';
                            state <= COUNTER_RESET;
                        end if;

                    when STORE =>
                        timerReset <= '1';
						endOfBitRead <= '0';
                        
                        if (index < 40) then
                            -- Go back to RECEIVING0 to read the next bit
							index := index +1; -- increments the number of bit read
		                    stateAfterCounterReset <= RECEIVING0;
		                    state <= COUNTER_RESET;
                        end if;

                        if (index = 40) then -- all the bits have been read
							stateAfterCounterReset <= ENDTRANSACTION;
		                    state <= COUNTER_RESET;
                        end if;

					when ENDTRANSACTION =>
                        if data_in = '1' then -- count the time when it was at '0'
                            timerReset <= '1';
							-- we check if we have receive GND for 50ms at the end of the 40th bit read
                            if (count >= dht11_bit_duration - errorMargin) and (count <= dht11_bit_duration + errorMargin) then
                                -- Go to SET_DO 
                                state <= SET_DO;
                            else -- Protocol error and go back to IDLE
                                pe <='1';
                                state <= IDLE;
                            end if;
                        elsif (count > dht11_bit_duration + errorMargin ) then -- Protocol error and go back to IDLE
                            pe <='1';
                            timerReset <= '1';
                            state <= IDLE;
                        end if;

					when SET_DO =>
                        do <= currentRead;
                        endOfRead <= '1';
                        b <= '0';
                        data_drv <= '0';
						resetSr <= '1'; -- reset the shift register
                        state <= IDLE;
        
                    when COUNTER_RESET =>
                        timerReset <= '0';
                        state <= stateAfterCounterReset;

                    when STARTING1 => --We send GND for at least 18000
                        pe <='0';
                        data_drv <= '1'; -- We take control
                        b <='1';  -- busy because we are receiving data

                        if (count >= dht11_start_duration_min ) --TODO
                        then -- Go to STARTING2 after having reseted the counter
                            stateAfterCounterReset <= STARTING2;
                            timerReset <= '1';
                            state <= COUNTER_RESET;
                        end if;


                    when STARTING2 => -- We send VCC for at least 20 - 40 us
                        data_drv <= '0';
                        --we wait until data_in = 0 so we can know how much time it has been to 1
                        if data_in = '0' and count > 0 then -- (count >0 to be sure that the counter has been reseted, esle we have a protocol error)
                            if (count >= dht11_start_to_ack_min - errorMargin and count <= dht11_start_to_ack_max + errorMargin) then -- Go to SENDING0 after having reseted the counter
                                stateAfterCounterReset <= SENDING0;
                                timerReset <= '1';
                                state <= COUNTER_RESET;
                            else -- Protocol error and go back to IDLE
                                pe <= '1';
                                timerReset <= '1';
                                state <= IDLE ;
                            end if;
                        elsif ( count > dht11_start_to_ack_max + errorMargin) then -- Protocol error and go back to IDLE
                            pe <= '1';
                            timerReset <= '1';
                            state <= IDLE;
                        end if;
                        

                    when SENDING0 => -- Receiving GND for 80 us

                        if data_in = '1' then -- count the time when it was at '0'
                            if (count >= dht11_ack_duration - errorMargin) and (count <= dht11_ack_duration + errorMargin) then -- Go to SENDING1 after having reseted the counter
                                stateAfterCounterReset <= SENDING1;
                                timerReset <= '1';
                                state <= COUNTER_RESET;
                            else -- Protocol error and go back to IDLE
                                pe <= '1';
                                -- data_drv <= '0'; -- We release control because by default it is at VC
                                b <= '0';
                                timerReset <= '1';
                                state <= IDLE ;
                            end if;
                        elsif ( count > dht11_ack_duration + errorMargin) then -- Protocol error and go back to IDLE
                            pe <= '1';
                            timerReset <= '1';
                            state <= IDLE;
                        end if;

                    when SENDING1 => -- Receiving VCC for 80 us

                        if data_in='0' then -- count the time when it was at '1'
                            if (count >= dht11_ack_to_bit - errorMargin) and (count <= dht11_ack_to_bit + errorMargin) then 
                                -- Go to RECEIVING0 after having reseted the counter
                                stateAfterCounterReset <= RECEIVING0;
                                timerReset <= '1';
                                state <= COUNTER_RESET;
                                readStarted <= '1';
                            else -- Protocol error and go back to IDLE
                                pe <= '1';
                                timerReset <= '1';
                                state <= IDLE;
                            end if;
                        elsif ( count > dht11_ack_to_bit + errorMargin) then -- Protocol error and go back to IDLE
                            pe <= '1';
                            timerReset <= '1';
                            state <= IDLE;
                        end if;

					-- We start to receive the bits
                    when RECEIVING0 =>  -- Receive GND for 80 us
                        endOfBitRead <= '0';
                        if data_in = '1' then -- count the time when it was at '0'
                            if (count >= dht11_bit_duration - errorMargin) and (count <= dht11_bit_duration + errorMargin) then
                                -- Go to RECEIVING1 after having reseted the counter
                                stateAfterCounterReset <= RECEIVING1;
                                timerReset <= '1';
                                state <= COUNTER_RESET;
                            else -- Protocol error and go back to IDLE
                                pe <='1';
                                timerReset <= '1';
                                state <= IDLE;
                            end if;
                        elsif (count > dht11_bit_duration + errorMargin ) then -- Protocol error and go back to IDLE
                            pe <='1';
                            timerReset <= '1';
                            state <= IDLE;
                        end if;

                    when RECEIVING1 => -- Receive VCC for 80 us
                        if data_in = '0' then -- count the time when it was at '1'    
                            if (count >= dht11_bit1_to_next - errorMargin) and (count <= dht11_bit1_to_next + errorMargin) then
                                -- for the shift register
								bitRead <= '1';
                                endOfBitRead <= '1'; 

                                -- Go to STORE 
                                state <= STORE;

                            elsif (count >= dht11_bit0_to_next_min - errorMargin) and (count <= dht11_bit0_to_next_max + errorMargin) then
                                -- for the shift register
								bitRead <= '0';
                                endOfBitRead <= '1'; 

                                -- Go to STORE 
                                state <= STORE;
                            else -- Protocol error and go back to IDLE
                                pe <= '1';
                                timerReset <= '1';
                                state <= IDLE;
                            end if;
                
                        elsif (count > dht11_bit1_to_next + errorMargin) then -- Protocol error and go back to IDLE
                            pe <= '1';
                            timerReset <= '1';
                            state <= IDLE;
                        end if;
                
                    when others =>
                        timerReset <= '1';
                        state <= INIT;
                end case;
            end if;
        end if;
    end process P1;
  
   
end architecture rtl;
