-- AXI4 lite wrapper around the DHT11 controller dht11_ctrl(rtl). It contains two 32-bits read-only registers:
--
-- Address                Name    Description
-- 0x00000000-0x00000003  DATA    read-only, 32-bits, data register
-- 0x00000004-0x00000007  STATUS  read-only, 32-bits, status register
-- 0x00000008-...         -       unmapped
--
-- Writing to DATA or STATUS shall be answered with a SLVERR response. Reading or writing to the unmapped address space [0x00000008,...] shall be answered with a DECERR response.
--
-- The reset value of DATA is 0xffffffff.
-- DATA(31 downto 16) = last sensed humidity level, Most Significant Bit: DATA(31).
-- DATA(15 downto 0) = last sensed temperature, MSB: DATA(15).
--
-- The reset value of STATUS is 0x00000000.
-- STATUS = (2 => PE, 1 => B, 0 => CE, others => '0'), where PE, B and CE are the protocol error, busy and checksum error flags, respectively.
--
-- After the reset has been de-asserted, the wrapper waits for 1 second and sends the first start command to the controller. Then, it waits for one more second, samples DO(39 downto 8) (the sensed values) in DATA, samples the PE and CE flags in STATUS, and sends a new start command to the controller. And so on every second, until the reset is asserted. When the reset is de-asserted, every rising edge of the clock, the B output of the DHT11 controller is sampled in the B flag of STATUS.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_pkg.all;

entity dht11_axi is
    generic(
        freq:       positive range 1 to 1000 -- Clock frequency (MHz)
    );
    port(
        aclk:           in  std_ulogic;  -- Clock
        aresetn:        in  std_ulogic;  -- Synchronous, active low, reset
        
        --------------------------------
        -- AXI lite slave port s0_axi --
        --------------------------------
        -- Inputs (master to slave) --
        ------------------------------
        -- Read address channel
        s0_axi_araddr:  in  std_ulogic_vector(29 downto 0);
        s0_axi_arprot:  in  std_ulogic_vector(2 downto 0); -- wth ?
        s0_axi_arvalid: in  std_ulogic;
        -- Read data channel
        s0_axi_rready:  in  std_ulogic;
        -- Write address channel
        s0_axi_awaddr:  in  std_ulogic_vector(29 downto 0);
        s0_axi_awprot:  in  std_ulogic_vector(2 downto 0);  -- wth ?
        s0_axi_awvalid: in  std_ulogic;
        -- Write data channel
        s0_axi_wdata:   in  std_ulogic_vector(31 downto 0); -- do nothing
        s0_axi_wstrb:   in  std_ulogic_vector(3 downto 0); -- do nothing
        s0_axi_wvalid:  in  std_ulogic; -- do nothing
        -- Write response channel
        s0_axi_bready:  in  std_ulogic;
        -------------------------------
        -- Outputs (slave to master) --
        -------------------------------
        -- Read address channel
        s0_axi_arready: out std_ulogic;
        -- Read data channel
        s0_axi_rdata:   out std_ulogic_vector(31 downto 0);
        s0_axi_rresp:   out std_ulogic_vector(1 downto 0);
        s0_axi_rvalid:  out std_ulogic;
        -- Write address channel
        s0_axi_awready: out std_ulogic; 
        -- Write data channel
        s0_axi_wready:  out std_ulogic;
        -- Write response channel
        s0_axi_bresp:   out std_ulogic_vector(1 downto 0);
        s0_axi_bvalid:  out std_ulogic;

        data_in:        in  std_ulogic;
        data_drv:       out std_ulogic
  );
end entity dht11_axi;

architecture rtl of dht11_axi is

    signal start:  std_ulogic;
    signal pe:     std_ulogic;
    signal b:      std_ulogic;
    signal ce:     std_ulogic;
    signal do:     std_ulogic_vector(39 downto 0);
    signal data:   std_ulogic_vector(31 downto 0);
    signal status: std_ulogic_vector(31 downto 0);
    
    -- Counter
    signal timerReset : std_ulogic ;
    signal count : integer;
    signal pulse : std_ulogic;    

    -- State
    type STATE_TYPE is (INIT, WAITING1, WAITING2, SEND_START);
    signal state: STATE_TYPE;
    type AXI_STATE is (IDLE, ACK, ANSWER);--, WAITING);
	signal axiStateWrite, axiStateRead : AXI_STATE ;

	-- local signal
	signal araddr_local: std_ulogic_vector(29 downto 0);
	signal awaddr_local: std_ulogic_vector(29 downto 0);
	

begin

    u0: entity work.dht11_ctrl(rtl)
    generic map(
        freq => freq
    )
    port map(
        clk      => aclk,
        srstn    => aresetn,
        start    => start,
        data_in  => data_in,
        data_drv => data_drv,
        pe       => pe,
        b        => b,
        do       => do
    );

    timer: entity work.timer(arc)
    generic map(
        freq => freq ,
        timeout => 1
    )
    port map(
        clk      => aclk,
        sresetn    => aresetn,
        pulse  => pulse
    );

	-- COUNTER 
    Counter: process(aclk, timerReset)
      begin
        if rising_edge(aclk) then
              if aresetn = '0' or timerReset = '1' then
                count <= 0;
              elsif pulse = '1' then 
                count <= count + 1;
              end if;
        end if; 
      end process Counter;

    P1: process(aclk, state)
    begin
        if rising_edge(aclk) then
            if aresetn = '0'
            then
                state <= INIT;
                -- reset counter
                timerReset <= '1';
            
			else
				status(1) <= b;  -- every rising edge of the clock, the B output of the DHT11 controller is sampled in the B flag of STATUS
				-- By default, the counter is not reseted and start is at 0
				timerReset <= '0';
				start <= '0';
		        case state is
		            when INIT =>
		               -- Reset data and status
		                data <= (others => '1'); -- Set to 0xfffffffffff
		                status <= (others => '0'); -- Set to 0x0000000
		                
		                if aresetn = '1' then  -- reset has been de-asserted, we reset the counter to wait for 1 second
		                    state <= WAITING1;
							timerReset <= '1';
		                end if;

		            when WAITING1 => 
						-- sample data
		                data <= do(39 downto 8);                    
		                if count >= 1000000 then -- wait 1 second
		                    state <= SEND_START; 
		                    timerReset <= '1';
		                end if;

		            when SEND_START => 
		                start <= '1';  -- send START for 1 clock cycle
		                state <= WAITING2;  
		            
		            when WAITING2 =>
						-- sample status and data
						status <= (2 => pe, 1 => b, 0 => ce, others => '0');
		                data <= do(39 downto 8);
		                if count >= 1000000 then  -- wait for 1 more second
		                    state <= SEND_START;
		                    timerReset <= '1';
		                end if;
		                
		            when others =>
		                state <= INIT;
				end case ;
			end if;

        end if;
    end process P1;

	CheckSum: process(do)
		variable temp : unsigned(7 downto 0);
	begin
		
        temp := unsigned(do(39 downto 32))
            + unsigned(do(31 downto 24))
            + unsigned(do(23 downto 16))
            + unsigned(do(15 downto 8));

        if (unsigned(do(7 downto 0)) /= temp) then
            ce <= '1';
        else
			ce <= '0';
		end if;

	end process CheckSum;   


    Read: process(aclk)
    begin
        if rising_edge(aclk)
        then
            case axiStateRead is
                when IDLE =>
					-- reset all the signal to zero
			        s0_axi_arready <= '0';
			        s0_axi_rvalid <= '0';
			        
			        if s0_axi_arvalid = '1' then
						-- set ARREADY to 1 for 1 clock cycle
						s0_axi_arready <= '1';
						araddr_local <= s0_axi_araddr;
						-- GO to ACK State
			            axiStateRead <= ACK;
			        end if;

                when ACK =>
                    s0_axi_arready <= '0';

					-- we respond RVALID and RDATA and RRESP according to the address received
                    s0_axi_rvalid <= '1';
					
	                case to_integer(unsigned(araddr_local)) is
						when 0 to 3 => -- read Data
							s0_axi_rdata <= data;
							s0_axi_rresp <= axi_resp_okay;
				
						when 4 to 7 => -- read Status
							s0_axi_rdata <= status;
							s0_axi_rresp <= axi_resp_okay;

						when others => -- Address invalid
							s0_axi_rresp <= axi_resp_decerr;
							s0_axi_rdata <= (others => '0');
					end case;
					-- Go to ANSWER State
				    axiStateRead <= ANSWER;

                when ANSWER =>
                    -- WE can answer only if RREADY if set to 1 by the master
    				if s0_axi_rready = '1' 
					then -- in this case, we de-assert RVALID and we go back to IDLE
					    axiStateRead <= IDLE;	
						s0_axi_rvalid <= '0';		
				    end if;

				when others =>
				    axiStateRead <= IDLE;                    
                                           
            end case;
        end if;
    
    end process Read;
    
    WRITE: process(aclk)
    begin
        if rising_edge(aclk)
        then
            case axiStateWrite is 
                when IDLE =>
					-- reset all the signal to zero
				    s0_axi_awready <= '0';
			        s0_axi_wready <= '0';
			        s0_axi_bvalid <= '0';
			        
				    if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' -- If we receive these 2 signals are asserted high simultaneously
				    then
						-- set AWREADY and WREADY to 1 for 1 clock cycle
						s0_axi_awready <= '1'; 
				    	s0_axi_wready <= '1';
				    	awaddr_local <= s0_axi_awaddr;
						-- Go to ACK state
				        axiStateWrite <= ACK;
				    end if;
			        
                when ACK =>
				    s0_axi_awready <= '0';
			        s0_axi_wready <= '0';
					
					-- we respond BVALID and BRESP with an error according to the address
					s0_axi_bvalid <= '1';
			       	case to_integer(unsigned(awaddr_local)) is
						when 0 to 7 =>
							s0_axi_bresp <= axi_resp_slverr;
						when others =>
							s0_axi_bresp <= axi_resp_decerr;
					end case;
					-- Go to ANSWER State
					axiStateWrite <= ANSWER;
				
			    when ANSWER =>
					-- WE can answer only if BREADY if set to 1 by the master
					if s0_axi_bready = '1'
					then  -- in this case, we de-assert BVALID and we go back to IDLE
					    axiStateWrite <= IDLE;
						s0_axi_bvalid <= '0';
					end if;
				  
				when others =>
				    axiStateWrite <= IDLE;
		    end case;
			        
		end if;
    end process WRITE;

end architecture rtl;
