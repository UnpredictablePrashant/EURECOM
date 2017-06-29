
library IEEE;
use IEEE.std_logic_1164.all;
use work.dht11_pkg.all;
use ieee.numeric_std.all;

entity fin_msm is
	generic(
        freq:    positive range 1 to 1000 -- Clock frequency (MHz)
    );
	port (clk:      in  std_ulogic;
		srstn:    in  std_ulogic; -- Active low synchronous reset
		start:    in  std_ulogic;
		data_in : in std_ulogic;
		data_drv: out std_ulogic;
		pe:       out std_ulogic; -- Protocol error
		b:        out std_ulogic; -- Busy
		do:       out std_ulogic_vector(39 downto 0) -- Read data
	);

end entity fin_msm;

architecture FiniteSM of fin_msm is
	type machine_state is (RESET,RTInitoIdle,RTRestoIni,IDLE,INIT,RT1,RT2,RT3,RT4,RT5,RT6,MCU_DRIVES_LOW,MCU_DRIVES_HIGH,DHT_DRIVES_LOW,DHT_DRIVES_HIGH,DHT_DATA_HIGH,DHT_DATA_LOW,EOT,RTEOT);
	    	signal state : machine_state;
		signal next_state:machine_state;
		signal count,bitcount: integer;
		signal timer_reset :std_ulogic;
		signal reg,read_data: std_ulogic_vector(39 downto 0);
		signal shift,bitcounter_reset,shiftregister_reset : std_ulogic;
		signal do_bit,eotbit,pulse : std_ulogic;

	begin	

		tim: entity work.timer(arc) --map the timer
		generic map(
		        freq    => freq,
			timeout => 1
		)
		port map(
		        clk =>clk,
			sresetn => srstn,
			pulse => pulse
		);

		shiftregister: entity work.sr(arc) --map the shift register
      		port map (
        		clk => clk,
        		srstn => srstn,
        		do_bit => do_bit,
    			do => read_data,
        		shift => shift,
			shiftregister_reset => shiftregister_reset
           	);

		stateRegister:process(clk) --reset of the Mealy state machine + synchronous changes of state of the state machine on rising_edge of the clock
		begin 		
			if clk'event and clk = '1' then 			
				if srstn = '0' then -- synchronous, active low, reset				
					state <= RESET;
				else
					state <= next_state;
	 			end if;		 		 	
			end if;
	 	end process stateRegister	;


		p2: process(state,start,count,data_in,bitcount) -- Mealy state machine
		begin
			next_state <= state; --by default, no changes of state
			
			case state is 
				when RESET => --state to reset the fsm	
					timer_reset <= '1';
          next_state <= RTRestoIni;
					shiftregister_reset <='1';
					bitcounter_reset <='1';
					data_drv <='0';
					pe <='0';
					shift <= '0';
					do_bit <='0';
					eotbit<='0';
					do <= (others => '0'); -- aggregate notation
	
				when RTRestoIni => -- set low the reset signal previously set high
					timer_reset <= '0';
					next_state <= INIT;
					b <= '0';
					shiftregister_reset <='0';
					bitcounter_reset <='0';
					
				when INIT => -- we wait for 1 second 
					b <= '1';
					if (count > dht11_reset_to_start_min ) then 
						next_state <= RTInitoIdle;
						timer_reset <='1'; -- reset the timer
						b <= '0';
					else 
						next_state <= INIT;
          end if;
				
				when RTInitoIdle => -- stop the reset of the timer
					timer_reset <= '0';
					next_state <= IDLE;
					
				

				when IDLE => -- if start button is pressed, we start communication with the sensor, we wait otherwise
					eotbit <= '0';
					shiftregister_reset <='0';
					bitcounter_reset <='0';
					b <= '0';
					if start = '1' then -- start the communication
						next_state<=RT1;
						data_drv <='1'; -- we pull down voltage by setting data_drv to 0
						b <= '1';
						timer_reset <= '1';
						bitcounter_reset<='1';
						shiftregister_reset <='1';
						pe <= '0';	
					else 
						next_state <= IDLE;
					end if;

				
				when RT1 => -- set low the signals set high on previous state
					next_state <= MCU_DRIVES_LOW;
					timer_reset <= '0';
					bitcounter_reset<='0';
					shiftregister_reset <='0';
					pe <= '0';
					
				when MCU_DRIVES_LOW =>
					if (count > dht11_start_duration_min) then --if the voltage was pull down for more than 18ms						
						data_drv <='0'; -- we stop pulling the voltage down
						timer_reset <= '1'; -- we reset the timer
						next_state <= RT2; -- switch to next state
					else 
						next_state <= MCU_DRIVES_LOW;
					end if;

				when RT2 =>
					next_state <= MCU_DRIVES_HIGH;
					timer_reset <= '0';
			
				when MCU_DRIVES_HIGH => -- the voltage has to be pulled up for 20-40µs and we wait the response of DHT11
					if (falling_edge(data_in))then -- if we have an answer from DHT11
						if count > dht11_start_to_ack_min -5  then 	-- if it was after 15µs, we can reset timer
							timer_reset <= '1';
							if (count > dht11_start_to_ack_max + 5) then -- if it was after 45µs, we consider it as a protocol error
								pe <= '1';
								next_state <= IDLE;
							else 
								next_state<= RT3; --if it was between 15µs and 45µs, we switch to next state
							end if;
						else --if it was before 15µs, this is a protocol error
							-- next_state <= MCU_DRIVES_HIGH;
							pe <= '1';
								next_state <= IDLE;
						end if;
					end if;
					
				
				when RT3 =>
					next_state <= DHT_DRIVES_LOW;
					timer_reset <= '0';
					

				when DHT_DRIVES_LOW =>	--dht sends out response and keep it for at least 80µs 
					if (data_in'event and data_in = '1') then -- we wait for dht to stop sending out the response
						if count > dht11_ack_duration - 5 then -- if it was after 75µs, we can reset the timer
							timer_reset <= '1';
							if (count > dht11_ack_duration + 5) then --if it was after 85µs, we consider it as a protocol error
								pe <= '1';
								next_state <= IDLE;
							else
								next_state<= RT4; --else we switch to next state
							end if;
						else -- if it was before 75µs, this is a protocol error
							-- next_state <= DHT_DRIVES_LOW;
							pe <= '1';
							next_state <= IDLE;
						end if;
					end if;
			
				when RT4 =>
					next_state <= DHT_DRIVES_HIGH;
					timer_reset <= '0';
				
				when DHT_DRIVES_HIGH => --dht pulls up voltage and keeps it for 80µs
					if (data_in'event and data_in = '0') then -- we wait for dht to stop pulling up voltage
			 			if count > dht11_ack_to_bit -5   then -- if it was between the margin 75-85µs, we go to next state
							next_state <= RT5;
							timer_reset <= '1';
							if (count > dht11_ack_to_bit +5) then -- else this is a protocol error
								pe <= '1';
								next_state <= IDLE;
							else
								next_state<= RT5;						
							end if;
						else -- if it was before 75µs, this is a protocol error
							--next_state <= DHT_DRIVES_HIGH;
								pe <= '1';
								next_state <= IDLE;
						end if;
					end if;
				
				when RT5 =>
					next_state <= DHT_DATA_LOW;
					timer_reset <= '0';
					shift <= '0';				

				when DHT_DATA_LOW => -- dht11 starts to transmit 1 bit data for 50µs
					if (bitcount <= 39) then		-- if we have recieved less than 40 bits, we recieve the bit			
						if (data_in'event and data_in = '1') then -- if the end of the transmission happens
							if count > dht11_bit_duration - 5 then -- between 45µs and 55µs, we go to next state
								next_state <= RT6;
								timer_reset <= '1';
								if (count > dht11_bit_duration +5) then -- if it took more than 55µs, this is a protocol error
									pe <= '1';
									next_state <= IDLE;
								else
									next_state<= RT6;						
								end if;
							else -- if it was less than 45µs, this is also a protocol error
								-- next_state <= DHT_DATA_LOW;
								pe <= '1';
								next_state <= IDLE;
							end if;
						end if;
					else   -- else, we have recieved 40bits, it means end of transmission
						next_state <= RTEOT;
						eotbit <= '1';
					end if;
			
				
				when RT6 =>
					next_state <= DHT_DATA_HIGH;
					timer_reset <= '0';
				
				when DHT_DATA_HIGH => -- 26-28µs voltage-length means 0 and 70µs means 1 
					if (bitcount <= 39) then
						if count > dht11_bit1_to_next + 10 then --timeout 
							pe <= '1';
							next_state <= IDLE;						
						end if;
						if (data_in = '0') then
							if ((count > dht11_bit0_to_next_min - 10 and count < dht11_bit0_to_next_max + 10) or (count > dht11_bit1_to_next - 10 and count < dht11_bit1_to_next + 10)) then -- we are recieving a bit
								if (count > dht11_bit0_to_next_min - 10 and count < dht11_bit0_to_next_max + 10) then
									do_bit <= '0';
									shift <='1';
									timer_reset <= '1';
									next_state <= RT5;
								elsif ( count > dht11_bit1_to_next - 10 and count < dht11_bit1_to_next + 10) then -- we are recieving a 1
									do_bit <= '1';
									shift <='1';
									timer_reset <= '1';
									next_state <= RT5;
								else
									pe <= '1';
									next_state <=IDLE;
								end if;
							else -- protocol error
								--next_state <= DHT_DATA_HIGH;
								pe <= '1';
								next_state <= IDLE;
							end if;
						end if;	
					end if;
			
				when RTEOT => -- this is the end of transmission 
					timer_reset <= '0';
					next_state <=EOT;
					

				when EOT => -- when the last bit is transmitted, dht11 pulls down the voltage level and keeps it for 50µs
					if (count > dht11_bit_duration + 5 and data_in'event and data_in = '1' ) then 
						next_state <= IDLE;
						pe <= '1';
					end if;
					if count < dht11_bit_duration + 5 and count > dht11_bit_duration - 5 and data_in'event and data_in = '1' then
						next_state <= IDLE;
						do <= read_data;
					end if;
					if count > dht11_bit_duration + 20 then --timeout 
						pe <='1';
						next_state <=IDLE;
					end if;	
				when others =>
                        		next_state <= RESET;
					
			end case;
		end process p2; 

	timecounter:process(clk) -- increment by one counter each µs, and reset with timer_reset
	begin
		if clk'event and clk = '1'  then
			if  srstn = '0' or timer_reset = '1' then --sync high reset
				count <= 0;
			elsif pulse = '1' then
				count <= count +1;
			end if;
		end if;
	end process timecounter;

	bitcounter:process(clk) --counter of bits increased each time we recieve a bit 
	begin
		if clk'event and clk = '1'  then
			if srstn = '0' or bitcounter_reset = '1' then
				bitcount <= 0;
			elsif shift = '1' then
				bitcount <= bitcount +1;
			end if;
		end if;
	end process bitcounter;

	

end architecture FiniteSM;
