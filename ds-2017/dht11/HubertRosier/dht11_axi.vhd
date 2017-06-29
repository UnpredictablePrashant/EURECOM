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
  signal pulse:  std_ulogic;
  signal s_reset_count_n:  std_ulogic;
  signal count:  integer;
  type states_sim is (WAITING1,SENDING_START,WAITING2);
  type states_write is (idle,ack,waiting);
  signal wstate: states_write;
  signal next_wstate: states_write;
  signal rstate: states_write;
  signal next_rstate: states_write;

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
  timer0 : entity work.timer(arc)
  generic map(
               freq => freq
             )
  port map(
            clk => aclk,
            sresetn => aresetn,
            pulse => pulse
          );


  COUNTER: process(aclk, s_reset_count_n)
  begin
    if aclk'event and aclk = '1' then
      if s_reset_count_n = '0' then
        count <= 0;
      elsif pulse = '1' then
        count <= count + 1;
      end if;
    end if;
  end process COUNTER;


  process(aclk)
    variable state: states_sim := WAITING1;
  begin 
    if rising_edge(aclk) then
      if aresetn='0' then
        data <= (others => '0');   -- reset data to 0x00000000
        status <= (others => '0'); -- reset status data to 0x00000000
        s_reset_count_n <= '0';    -- reset the counter
        state := WAITING1;         -- switch to state WAITING1
      else
        status(0) <= ce;
        status(1) <= b;
        status(2) <= pe;
        data <= do(39 downto 8);
        s_reset_count_n <= '1'; -- default value
        start <= '0';           -- default value
        if state = WAITING1 then  -- state where wait for 1s after reset
          if count >= 1000000 then
            s_reset_count_n <= '0'; -- reset the counter
            state := SENDING_START;
          end if; -- count
        elsif state = SENDING_START then -- send the start signal to start an acquisition
          start <= '1';
          state := WAITING2;
        elsif state = WAITING2 then
          if count >= 1000000 then  -- wait for 1s and send again a start signal
            s_reset_count_n <= '0';
            state := SENDING_START;
          end if; -- count
        end if; -- state
      end if; -- reset
    end if; -- aclk
  end process;

  -- Process that compute the checksum and check if it correcponds to the one send
  CHECK_CHECKSUM : process(do)
    variable computed_checksum : std_ulogic_vector(7 downto 0);
  begin
    computed_checksum := std_ulogic_vector(unsigned(do(39 downto 32)) + unsigned(do(31 downto 24)) + unsigned(do(23 downto 16)) + unsigned(do(15 downto 8))) ;
    if computed_checksum /= do(7 downto 0) then
      CE <= '1';
    else
      CE <= '0';
    end if;
  end process;

  -- Process that implements the finite state machine if the read process
  READ_STATE_M: process(rstate,s0_axi_arvalid,s0_axi_rready)
    variable raddr: std_ulogic_vector(29 downto 0);
  begin 
    case rstate is
   -- state = idle
      when idle =>        
        if s0_axi_arvalid = '1' then
	  next_rstate <= ack;
	end if;
   -- state = ack
      when ack =>
        if s0_axi_rready = '1' then
	  next_rstate <= idle;
	else 
	  next_rstate <= waiting;
	end if;
	raddr := s0_axi_araddr;
        if to_integer(unsigned(raddr)) < 4 then
          s0_axi_rdata <= data;
          s0_axi_rresp <= axi_resp_okay;
        elsif to_integer(unsigned(raddr)) < 8 then
          s0_axi_rdata <= status;
          s0_axi_rresp <= axi_resp_okay;
        else  -- error bad addr
          s0_axi_rresp <= axi_resp_decerr;
        end if; -- addr readable ?
   -- state = waiting
      when waiting =>
        if s0_axi_rready = '1' then
	  next_rstate <= idle;
	end if;
        if to_integer(unsigned(raddr)) < 4 then -- if address < 0x0004 read data
          s0_axi_rdata <= data;
          s0_axi_rresp <= axi_resp_okay;
        elsif to_integer(unsigned(raddr)) < 8 then -- if 0x04<address<0x08 read status
          s0_axi_rdata <= status;
          s0_axi_rresp <= axi_resp_okay;
        else  -- error bad addr
          s0_axi_rresp <= axi_resp_decerr;
        end if; -- addr readable ?
    end case;
   end process READ_STATE_M;

  s0_axi_arready <= '1' when rstate = ack  else '0';
  s0_axi_rvalid  <= '0' when rstate = idle else '1';

  -- Process that implements the finite state machine if the write process
  WRITE_STATE_M: process(wstate,s0_axi_awvalid,s0_axi_wvalid,s0_axi_bready)
    variable waddr: std_ulogic_vector(29 downto 0);
  begin 
    case wstate is
    -- state = idle
      when idle =>
        if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
	  next_wstate <= ack;
	end if;
   -- state = ack
      when ack =>
        if s0_axi_bready = '1' then
	  next_wstate <= idle;
	else 
	  next_wstate <= waiting;
	end if;
	waddr := s0_axi_awaddr;
        if to_integer(unsigned(waddr)) < 8 then -- if address < 0x0008 send slave error
          s0_axi_bresp <= axi_resp_slverr;
        else                                    -- else send derror
          s0_axi_bresp <= axi_resp_decerr;
        end if; -- which addr
   -- state = waiting
      when waiting =>
        if s0_axi_bready = '1' then
	  next_wstate <= idle;
	end if;
        if to_integer(unsigned(waddr)) < 8 then -- if address < 0x0008 send slave error
          s0_axi_bresp <= axi_resp_slverr;
        else                                    -- else send derror
          s0_axi_bresp <= axi_resp_decerr;
        end if; -- which addr
    end case;
   end process WRITE_STATE_M;

  s0_axi_awready <= '1' when wstate = ack  else '0';
  s0_axi_wready  <= '1' when wstate = ack  else '0';
  s0_axi_bvalid  <= '0' when wstate = idle else '1';

  -- Process that updates the states 
  process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then 
	wstate <= idle;
	rstate <= idle;
      else
	wstate <= next_wstate;
	rstate <= next_rstate;
      end if; -- reset
    end if; --aclk
  end process;

end architecture rtl;
