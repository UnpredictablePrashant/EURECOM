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
		freq:       positive range 1 to 1000:=1 -- Clock frequency (MHz)
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
		s0_axi_arprot:  in  std_ulogic_vector(2 downto 0);
		s0_axi_arvalid: in  std_ulogic;
		-- Read data channel
		s0_axi_rready:  in  std_ulogic;
		-- Write address channel
		s0_axi_awaddr:  in  std_ulogic_vector(29 downto 0);
		s0_axi_awprot:  in  std_ulogic_vector(2 downto 0);
		s0_axi_awvalid: in  std_ulogic;
		-- Write data channel
		s0_axi_wdata:   in  std_ulogic_vector(31 downto 0);
		s0_axi_wstrb:   in  std_ulogic_vector(3 downto 0);
		s0_axi_wvalid:  in  std_ulogic;
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
	signal mem_axi_raddr,mem_axi_waddr : std_ulogic_vector(29 downto 0);
	signal data:   std_ulogic_vector(31 downto 0);
	signal status: std_ulogic_vector(31 downto 0);
	constant mask:		std_ulogic_vector(29 downto 0) := "11" & x"FFFFFFC";
	constant min_data:	std_ulogic_vector(29 downto 0) := "00" & x"0000000";
	constant max_data:	std_ulogic_vector(29 downto 0) := "00" & x"0000003";
	constant min_status:	std_ulogic_vector(29 downto 0) := "00" & x"0000004";
	constant max_status:	std_ulogic_vector(29 downto 0) := "00" & x"0000007";
	signal raddr_ready,waddr_ready:     std_ulogic;
	
	type read_state_type is (RESET,IDLE,READ);
	signal state_read,next_state_read : read_state_type;
	
	type write_state_type is (RESET,IDLE,WRITE,DECERROR,SERROR);
	signal state_write,next_state_write: write_state_type;
	
	signal count:		integer range 0 to freq * 1000000;

begin

	u0: entity work.dht11_ctrl(rtl) -- mapping of the controller
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


	process(aclk) --reset of the mealy state machines + synchronous changes of state of the state machines on rising_edge of the clock 
	begin 		
		if rising_edge(aclk) then 			
			if aresetn = '0' then -- synchronous, active low, reset				
				state_read <= RESET;
				state_write <= RESET;
			else
				state_read <= next_state_read;
				state_write <= next_state_write;
 			end if;		 		 	
		end if;
	end process ;
		
	Counter: process(aclk) -- counter to count 1 sec
       	begin
      	if(rising_edge(aclk)) then
 		start <= '0';
         	if(aresetn='0') then
          		count <= 0;
         	else
           		if(count = freq * 1000000) then   
	     			start <= '1';            
	     			count <= 0;
          		 else
	     			count <= count + 1;
           		end if;
          	end if;
        end if;
        end process Counter;


	Readprocess: process(state_read, s0_axi_arvalid, mem_axi_raddr, s0_axi_rready) -- state machine to read
  begin
  	next_state_read <= state_read; -- by default, the state stays the same
  	case (state_read) is
		
			when RESET => -- reset state, we drive all signal low
				s0_axi_arready  <= '0';
      	s0_axi_rvalid   <= '0';
				raddr_ready <= '0';
				next_state_read <=IDLE;

		  when IDLE  =>
				s0_axi_arready  <= '0';
		    s0_axi_rvalid   <= '0';
			  if (s0_axi_arvalid = '1') then -- when a read request is acknowledged, we assert arready high for one clock period and sample the address
					s0_axi_arready <= '1'; 
					raddr_ready <= '1';
					next_state_read <=READ;               			
		    end if;

		   	when READ =>
				s0_axi_arready <= '0'; 
				raddr_ready <= '0';
		    if (s0_axi_rready = '1') then -- 	The read request is completed on the rising edge of the clock where ARVALID and ARREADY are both asserted high
					if mem_axi_raddr >= min_data and  mem_axi_raddr <= max_status then
						s0_axi_rresp <= axi_resp_okay; 
					elsif mem_axi_raddr > max_status then
						s0_axi_rresp <= axi_resp_decerr;
					else
						s0_axi_rresp <= axi_resp_decerr;
					end if ; 
					s0_axi_rvalid <= '1'; --assert rvalid high
		      next_state_read <= IDLE;
				end if; 
	
			
  	end case;
	end process Readprocess;


	Writeprocess: process(state_write,mem_axi_waddr, s0_axi_awvalid,s0_axi_bready,s0_axi_wvalid) -- state machine to write
        begin
        	next_state_write <= state_write;
         	case (state_write) is
		
		when RESET =>
			s0_axi_awready  <= '0';
            		s0_axi_wready   <= '0';
           		s0_axi_bvalid   <= '0';
			waddr_ready <= '0';
			next_state_write <=IDLE;

          	when IDLE  =>
			s0_axi_awready  <= '0';
			s0_axi_wready   <= '0';
            		s0_axi_bvalid   <= '0';
			waddr_ready <= '1';
	     		if (s0_axi_wvalid = '1' and  s0_axi_awvalid = '1') then
				s0_axi_awready <= '1'; 
				s0_axi_wready <= '1'; 
				next_state_write <=WRITE;               			
             		end if;

           	when WRITE =>
			s0_axi_awready <= '0';
			waddr_ready <= '0';
			s0_axi_wready <= '0';  
				if ( s0_axi_bready = '1') then
					if mem_axi_waddr >= min_data and  mem_axi_waddr <= max_status then
						s0_axi_bresp <= axi_resp_slverr;
						s0_axi_bvalid <= '1';
						next_state_write <= IDLE;
					else 
						s0_axi_bresp <= axi_resp_decerr;
						s0_axi_bvalid <= '1';
						next_state_write <= IDLE;
					end if ; 
				end if;
       
		when SERROR => 
			waddr_ready <= '0'; 
			if ( s0_axi_bready = '1') then
				s0_axi_bresp <= axi_resp_slverr ;
				s0_axi_bvalid <= '1';
				next_state_write <= IDLE;
			end if;
		when DECERROR =>
			waddr_ready <= '0'; 
			if ( s0_axi_bready = '1') then
				s0_axi_bresp <= axi_resp_decerr;
				s0_axi_bvalid <= '1';
				next_state_write <= IDLE;
			end if;
						
          	end case;
        end process Writeprocess;

	

	Multiplexer: process(mem_axi_raddr, data, status) -- multiplexer to choose if the address corresponds to the status or the the data location
        begin
            if (to_integer(unsigned(mem_axi_raddr)) >= to_integer(unsigned(min_data)) and to_integer(unsigned(mem_axi_raddr)) <= to_integer(unsigned(max_data))) then
              s0_axi_rdata <= data;
            elsif (to_integer(unsigned(mem_axi_raddr)) >= to_integer(unsigned(min_status)) and to_integer(unsigned(mem_axi_raddr)) <= to_integer(unsigned(max_status))) then
              s0_axi_rdata <= status;
            end if;
        end process Multiplexer;


	DataRegisters: process(aclk) -- register to display either the data or the status
        begin        
          if aclk'event and aclk='1' then
            if aresetn='0' then
              data <= (others=>'1');
              status <= (others=>'0');
            else 
              data <= do(39 downto 8);
              status <= (2=>pe, 1=>b, 0=>ce, others=>'0');
            end if;
          end if;
        end process DataRegisters;
	
	ReadAddressRegister: process(aclk) --register to store the address where to read
        begin 
	if(aclk' event and aclk = '1') then
		if(aresetn = '0') then
			mem_axi_raddr <= (others => '0');
            	elsif (raddr_ready = '1') then
              		mem_axi_raddr <= s0_axi_araddr;
            	end if;
        end if;
        end process ReadAddressRegister; 

	WriteAddressRegister: process(aclk) --register to store the address where to write
        begin 
	if(aclk' event and aclk = '1') then
		if(aresetn = '0') then
			mem_axi_waddr <= (others => '0');
            	elsif (waddr_ready = '1') then
              		mem_axi_waddr <= s0_axi_awaddr;
            	end if;
        end if;
        end process WriteAddressRegister; 
	
	ChecksumDisplay : process(do) -- compute the checksum
    	begin
        	if std_ulogic_vector(unsigned(do(39 downto 32)) + unsigned(do(31 downto 24)) + unsigned(do(23 downto 16)) + unsigned(do(15 downto 8))) /= do(7 downto 0) then
            		ce <= '1';
       		else
            		ce <= '0';
        	end if;
   	end process ChecksumDisplay;
	

		

end architecture rtl;
