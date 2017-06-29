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

    type states is (idle, ack, waiting_dec, waiting_slv);
    type r_states is (idle, ack, waiting_data, waiting_status, waiting_dec);
    signal state : states;
    signal r_state : r_states;
    signal next_state : states;
    signal r_next_state : r_states;
    signal start_local : std_ulogic;
    signal rvalid_local : std_ulogic;

	signal dummy1: std_ulogic_vector(31 downto 0);
	signal dummy2: std_ulogic_vector(3 downto 0);
	signal dummy3: std_ulogic_vector(2 downto 0);

    signal next_rdata:   std_ulogic_vector(31 downto 0);
    signal next_rresp:   std_ulogic_vector(1 downto 0);
    signal next_bresp:   std_ulogic_vector(1 downto 0);
    signal rresp_local:   std_ulogic_vector(1 downto 0);
    signal bresp_local:   std_ulogic_vector(1 downto 0);
    signal start:  std_ulogic;
    signal pe:     std_ulogic;
    signal b:      std_ulogic;
    signal ce:     std_ulogic;
    signal do:     std_ulogic_vector(39 downto 0);
    signal data:   std_ulogic_vector(31 downto 0);
    signal next_data:   std_ulogic_vector(31 downto 0);
    signal status: std_ulogic_vector(31 downto 0);
    signal next_status: std_ulogic_vector(31 downto 0);
    signal timer_rst: std_ulogic;
    signal count:   natural;

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

    cksm: entity work.checksum(arc)
    port map(
        do  => do,
        ce  => ce
    );


    --s0_axi_awready <= '1' when state = ack else '0';
    --s0_axi_bvalid <= '0' when state = idle else '1';
    dummy3 <= s0_axi_arprot;
    dummy1 <= s0_axi_wdata;
    dummy2 <= s0_axi_wstrb; 

    P1: process (state, s0_axi_awvalid, s0_axi_wvalid, s0_axi_bready, s0_axi_awaddr, next_bresp)
    begin
		s0_axi_bresp <= next_bresp;
		bresp_local <= next_bresp;
		next_state <= state;

        case state is
            when idle =>
                s0_axi_awready <= '0';
                s0_axi_wready <= '0';
                s0_axi_bvalid <= '0';
                if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
                    next_state <= ack;
                end if;
            when ack =>
                --next_state <= waiting;
                s0_axi_awready <= '1';
                s0_axi_wready <= '1';
                s0_axi_bvalid <= '0';
                if (s0_axi_awaddr =         x"0000000" & "00"  or
                            s0_axi_awaddr = x"0000000" & "01"  or
                            s0_axi_awaddr = x"0000000" & "10"  or
                            s0_axi_awaddr = x"0000000" & "11" or
                            s0_axi_awaddr = x"000000"  & "000100"  or
                            s0_axi_awaddr = x"000000"  & "000101"  or
                            s0_axi_awaddr = x"000000"  & "000110"  or
                            s0_axi_awaddr = x"000000"  & "000111") then
                        --s0_axi_bresp <= axi_resp_slverr;
                        next_state <= waiting_slv;
                 else
                        next_state <= waiting_dec;
                 end if;
                
            when waiting_slv =>
                s0_axi_awready <= '0';
                s0_axi_wready <= '0';
                s0_axi_bvalid <= '1';

                s0_axi_bresp <= axi_resp_slverr;
				bresp_local <= axi_resp_slverr;

                if (s0_axi_bready = '1' ) then 
                    next_state <= idle;

                end if;
            when waiting_dec =>
                s0_axi_awready <= '0';
                s0_axi_wready <= '0';
                s0_axi_bvalid <= '1';
                s0_axi_bresp <= axi_resp_decerr;
				bresp_local <= axi_resp_decerr;

                if (s0_axi_bready = '1' ) then 
                    next_state <= idle;

                end if;
        end case;
    end process P1;

    P2: process (aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                state <= idle;
                r_state <= idle;
				data <= (others => '0');
				status <= (others => '0');
                --s0_axi_rdata <= (others => '0');
                --s0_axi_rresp <= "00";
                --s0_axi_bresp <= "00";
            else 
                state <= next_state;
                r_state <= r_next_state;
				data <= next_data;
				status <= next_status;
--                s0_axi_rdata <= next_rdata;
                next_rresp <= rresp_local;
                next_bresp <= bresp_local;
            end if;
        end if;
   end process P2;

    --s0_axi_arready <= '1' when r_state = ack else '0';
    --s0_axi_rvalid <= '0' when r_state = idle else '1';
    
    P3: process (r_state, s0_axi_arvalid, s0_axi_rready, rvalid_local, s0_axi_araddr, do, pe, b, ce, status, data, next_rresp)
    begin
		r_next_state <= r_state;
		next_data <= data;
		next_status <= status;
--        next_rdata <= s0_axi_rdata;
        s0_axi_rresp <= next_rresp;
        rresp_local <= next_rresp;
		s0_axi_rdata <= data;

        case r_state is
            when idle =>
                s0_axi_arready <= '0';
				next_data <= data;
                --s0_axi_rready <= '0';
                s0_axi_rvalid <= '0';
                rvalid_local <= '0';
                if s0_axi_arvalid = '1' then
                    r_next_state <= ack;
                end if;
            when ack =>
                s0_axi_arready <= '1';
                --s0_axi_rready <= '1';
                s0_axi_rvalid <= '0';
                rvalid_local <= '0';
                next_data <= do(39 downto 8);
                next_status <= (2 => pe, 1 => b, 0 => ce, others => '0');
                if (        s0_axi_araddr = x"0000000" & "00"  or
                            s0_axi_araddr = x"0000000" & "01"  or
                            s0_axi_araddr = x"0000000" & "10"  or
                            s0_axi_araddr = x"0000000" & "11") then
                        r_next_state <= waiting_data;
                elsif (     s0_axi_araddr = x"000000"  & "000100"  or
                            s0_axi_araddr = x"000000"  & "000101"  or
                            s0_axi_araddr = x"000000"  & "000110"  or
                            s0_axi_araddr = x"000000"  & "000111") then
                        r_next_state <= waiting_status;
                 else 
                        --s0_axi_rresp <= axi_resp_decerr;
                        r_next_state <= waiting_dec;
                 end if;
                
            when waiting_data =>
                next_data <= data;
                s0_axi_arready <= '0';
                --s0_axi_rready <= '0';
                s0_axi_rvalid <= '1';
                rvalid_local <= '1';
                s0_axi_rresp <= axi_resp_okay;
                rresp_local <= axi_resp_okay;
                --s0_axi_rdata <= data_local;
--				next_rresp <= axi_resp_okay;
                s0_axi_rdata <= data;
                if (s0_axi_rready = '1' and rvalid_local = '1') then
                    r_next_state <= idle;
                else 
                    r_next_state <= waiting_data;
                end if;
            
            when waiting_status =>
                s0_axi_arready <= '0';
                next_data <= data;
                --s0_axi_rready <= '0';
                s0_axi_rvalid <= '1';
                rvalid_local <= '1';
--				next_rresp <= axi_resp_okay;
                s0_axi_rdata <= status;
				s0_axi_rresp <= axi_resp_okay;
                rresp_local <= axi_resp_okay;
                --s0_axi_rdata <= status;

                if (s0_axi_rready = '1' and rvalid_local = '1') then -- NOT FOR 2008, add int signal. CHANGED.
                    r_next_state <= idle;
                else 
                    r_next_state <= waiting_status;
                end if;

            when waiting_dec =>
                s0_axi_arready <= '0';
                next_data <= data;
                --s0_axi_rready <= '0';
                s0_axi_rvalid <= '1';
                rvalid_local <= '1';
                s0_axi_rresp <= axi_resp_decerr;
                rresp_local <= axi_resp_decerr;
--				next_rresp <= axi_resp_decerr;

                if (s0_axi_rready = '1' and rvalid_local = '1') then -- not for 2008
                    r_next_state <= idle;
                else 
                    r_next_state <= waiting_dec;
                end if;
        end case;
    end process P3;



    P4: process(aclk)
        variable cnt: natural range 0 to freq * 1000000;
    begin
    if rising_edge(aclk) then
        start <= '0';
        if aresetn = '0' then
            cnt := 0;
            --data <= (others => '0');
            --status <= (others => '0');
        elsif cnt = freq * 1000000 then
            cnt := 0;
            start <= '1';
            --data <= do(39 downto 8);
            
        else
            cnt := cnt + 1;
        end if;
    end if;
  end process P4;
        

    

end architecture rtl;
