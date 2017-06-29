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
	signal data:   std_ulogic_vector(31 downto 0);
	signal status: std_ulogic_vector(31 downto 0);

type stato is (IDLE,READ,READ_VAL,READ_ERR,WRITE,WRITE_VAL,WRITE_ERR,WRITE_ERR_VAL);
SIGNAL current_state, next_state : stato;


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

NEXT_STATE_GENERATION:
	PROCESS(current_state, s0_axi_wvalid,s0_axi_awaddr,s0_axi_araddr,s0_axi_bready,s0_axi_rready)
	BEGIN
		CASE current_state IS 
			
			WHEN IDLE  => 
				IF s0_axi_arvalid = '0' THEN 
					IF s0_axi_wvalid ='1' and s0_axi_awvalid='1' THEN
						IF s0_axi_awaddr >= x"00000000" and s0_axi_awaddr <= x"00000003"  THEN
							next_state <=WRITE ;
						ELSE next_state <=WRITE_ERR ;
						END IF;
					ELSE 
						next_state <=IDLE ;	
					END IF;
				ELSE
					IF s0_axi_araddr >= x"00000000" and s0_axi_araddr <= x"00000003" THEN
						next_state <=READ ;
					ELSE next_state <=READ_ERR ;
					END IF;
		
				END IF;
			WHEN WRITE =>
				next_state <= WRITE_VAL;			

			WHEN WRITE_VAL => 
				IF s0_axi_bready = '0' THEN next_state <=WRITE_VAL ;
				ELSE next_state <= IDLE;
				END IF;

			WHEN WRITE_ERR =>
				next_state <= WRITE_ERR_VAL;
			
			WHEN WRITE_ERR_VAL => 
				IF s0_axi_bready = '0' THEN next_state <=WRITE_ERR_VAL ;
				ELSE next_state <= IDLE;
				END IF;

			WHEN READ =>
				next_state <= READ_VAL;

			WHEN READ_VAL => 
				IF s0_axi_rready = '0' THEN next_state <=READ_VAL ;
				ELSE next_state <= IDLE;
				END IF;
			
			WHEN READ_ERR => 
				IF s0_axi_rready = '0' THEN next_state <=READ_ERR ;
				ELSE next_state <= IDLE;
				END IF;

			WHEN OTHERS => 
				next_state <= IDLE;
		END CASE;	
	END PROCESS NEXT_STATE_GENERATION;


CURRENT_STATE_UPDATING:
	PROCESS(aclk)
	BEGIN
		IF RISING_EDGE(aclk)  THEN
			current_state<=next_state;
		END IF;
	END PROCESS CURRENT_STATE_UPDATING;

OUTPUT_GENERATION:
	PROCESS(current_state)
	BEGIN
		s0_axi_arready <= '0';
		-- Read data channel
		s0_axi_rdata <=(others=>'0');
		s0_axi_rresp <=(others=>'0');
		s0_axi_rvalid  <= '0';
		-- Write address channel
		s0_axi_awready <= '0';
		-- Write data channel
		s0_axi_wready <= '0';
		-- Write response channel
		s0_axi_bresp <=(others=>'0');
		s0_axi_bvalid <= '0';

		CASE current_state IS 
			WHEN IDLE => 
				s0_axi_arready <= '0';
				-- Read data channel
				s0_axi_rdata <=(others=>'0');
				s0_axi_rresp <=(others=>'0');
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '0';
				-- Write data channel
				s0_axi_wready <= '0';
				-- Write response channel
				s0_axi_bresp <=(others=>'0');
				s0_axi_bvalid <= '0';
			
			WHEN READ =>
				s0_axi_arready <= '1';
				-- Read data channel
				s0_axi_rdata <=do(39 downto 8);
				s0_axi_rresp <="00";
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '0';
				-- Write data channel
				s0_axi_wready <= '0';
				-- Write response channel
				s0_axi_bresp <=(others=>'0');
				s0_axi_bvalid <= '0';

			WHEN READ_VAL =>
				s0_axi_arready <= '0';
				-- Read data channel
				s0_axi_rdata <=do(39 downto 8);
				s0_axi_rresp <="00";
				s0_axi_rvalid  <= '1';
				-- Write address channel
				s0_axi_awready <= '0';
				-- Write data channel
				s0_axi_wready <= '0';
				-- Write response channel
				s0_axi_bresp <=(others=>'0');
				s0_axi_bvalid <= '0';
			
			WHEN READ_ERR =>
				s0_axi_arready <= '1';
				-- Read data channel
				s0_axi_rdata <=(others=>'0');
				s0_axi_rresp <="11";
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '0';
				-- Write data channel
				s0_axi_wready <= '0';
				-- Write response channel
				s0_axi_bresp <=(others=>'0');
				s0_axi_bvalid <= '0';
				

			WHEN WRITE => 
				s0_axi_arready <= '0';
				-- Read data channel
				s0_axi_rdata <=(others=>'0');
				s0_axi_rresp <=(others=>'0');
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '1';
				-- Write data channel
				s0_axi_wready <= '1';
				-- Write response channel
				s0_axi_bresp <="10";
				s0_axi_bvalid <= '0';
			
			WHEN WRITE_VAL => 
				s0_axi_arready <= '0';
				-- Read data channel
				s0_axi_rdata <=(others=>'0');
				s0_axi_rresp <=(others=>'0');
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '0';
				-- Write data channel
				s0_axi_wready <= '0';
				-- Write response channel
				s0_axi_bresp <="10";
				s0_axi_bvalid <= '1';

			WHEN WRITE_ERR => 
				s0_axi_arready <= '0';
				-- Read data channel
				s0_axi_rdata <=(others=>'0');
				s0_axi_rresp <=(others=>'0');
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '1';
				-- Write data channel
				s0_axi_wready <= '1';
				-- Write response channel
				s0_axi_bresp <="11";
				s0_axi_bvalid <= '0';

			WHEN WRITE_ERR_VAL => 
				s0_axi_arready <= '0';
				-- Read data channel
				s0_axi_rdata <=(others=>'0');
				s0_axi_rresp <=(others=>'0');
				s0_axi_rvalid  <= '0';
				-- Write address channel
				s0_axi_awready <= '0';
				-- Write data channel
				s0_axi_wready <= '0';
				-- Write response channel
				s0_axi_bresp <="11";
				s0_axi_bvalid <= '1';



		END CASE;	
	END PROCESS OUTPUT_GENERATION;

end architecture rtl;

