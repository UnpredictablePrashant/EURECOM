-- vim: set textwidth=0:
library ieee; -- to use ieee.std_logic_1164 package
use ieee.std_logic_1164.all; -- to use std_ulogic and std_ulogic_vector types
use work.dht11_pkg.all;
use ieee.math_real.all;

entity fsm is
	port(
		clk:           in  std_ulogic;
		srstn:         in  std_ulogic;
		count:         in  natural;
		start:         in  std_ulogic;
		rise:          in  std_ulogic;
		fall:          in  std_ulogic;
		shift:         out std_ulogic := '0';
		dout_sipo:     out std_ulogic;
		b:             out std_ulogic;
		pe:            out std_ulogic := '0';
		data_drv:      out std_ulogic := '0';
		timer_rst:     out std_ulogic
	);
end entity fsm;

architecture arc of fsm is
	type states is (init, idle, mcudrive1, mcudrive2, dhtdrive1, dhtdrive2, receive1, receive2);
	signal state : states := init;
    	signal next_state : states;
		signal b_local : std_ulogic;
        signal data_drv_local : std_ulogic;
        signal shift_count: natural;
        signal next_pe : std_ulogic;
        signal next_bit : std_ulogic;
        signal dout_sipo_local: std_ulogic;
        signal pe_local : std_ulogic;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if srstn = '0' then -- synchronous, active low, reset
				state <= init;
                b <= '0';
                data_drv <= '0';
                shift_count <= 0;
                pe <= '0';
                pe_local <= '0';
                dout_sipo <= '0';
                dout_sipo_local <= '0';
			else
                b <= b_local;
                data_drv <= data_drv_local;
                pe <= next_pe;
                pe_local <= next_pe;
                dout_sipo <= next_bit;
                dout_sipo_local <= next_bit;


                if (b_local = '0') then
                    shift_count <= 0;
                end if;

                if (state = receive2 and next_state = receive1) then
                    shift <= '1';
                    shift_count <= shift_count + 1;
                else
                    shift <= '0';
                end if;
                state <= next_state;
			end if;
		end if;
	end process;

	process(count, state, rise, fall, start, b_local, data_drv_local, pe_local, shift_count, dout_sipo_local) -- no next_state, next_pe, next_bit here, ok? not in our in class example. these are just outputs.
        variable ten_margin : natural;
        variable zero_low_margin: natural;
        variable zero_high_margin: natural;
        variable ms_margin : natural;
    	variable relax_margin : natural;

	begin
        ten_margin := 10;
        zero_low_margin := 10;
        zero_high_margin := 12;
        ms_margin := 1000;
		next_state <= state; -- by default, stay in same state
        data_drv_local <= '0';
        b_local <= '1';
		relax_margin := 500;
		
        next_pe <= pe_local;
        next_bit <= dout_sipo_local;


		case state is
	    	when init =>
                timer_rst <= '0';
                b_local <= '1';
                next_pe <= '0';
				next_bit <= dout_sipo_local; -- CHECK!
                if(count = dht11_reset_to_start_min) then
					next_state <= idle;
                    timer_rst <= '1';
                else 
                    next_state <= init;
				end if;
			when idle =>
                timer_rst <= '0';
				b_local <= '0';
                next_pe <= pe_local; 
				next_bit <= dout_sipo_local; -- CHECK!
				
				
				if(start = '1') then
					next_state <= mcudrive1;
                    data_drv_local <= '1'; 
                    b_local <= '1'; 
                    timer_rst <= '1';
					next_pe <= '0';
                else
                    next_state <= idle;
				end if;
			when mcudrive1 =>
                timer_rst <= '0';
                next_pe <= '0';
                data_drv_local <= '1';
				next_bit <= dout_sipo_local; -- CHECK!
                if(count = dht11_start_duration_min  + ms_margin) then -- +2ms for margin
            
                    next_state <= mcudrive2;
                    timer_rst <= '1';
                else
                    next_state <= mcudrive1;
				end if;
			when mcudrive2 =>
                timer_rst <= '0';
				data_drv_local <= '0';
		        next_pe <= '0';
				next_bit <= dout_sipo_local; -- CHECK!
                if( (fall = '1') and (count <= relax_margin )) then
                    next_state <= dhtdrive1;
                    timer_rst <= '1';

                elsif ((count <= relax_margin) and (fall = '0' )) then
                    next_state <= mcudrive2;
                else 
                    next_state <= idle;
                    next_pe <= '1';
				end if;
			when dhtdrive1 =>
		        next_pe <= '0';
                timer_rst <= '0';
				next_bit <= dout_sipo_local; -- CHECK!
                if((count <= relax_margin) and (rise = '1')) then
                    next_state <= dhtdrive2;
                    timer_rst <= '1';
                elsif ((count <= relax_margin) and (rise = '0')) then 
                    next_state <= dhtdrive1;
                else
					next_state <= idle;
					next_pe <= '1';
				end if;
			when dhtdrive2 =>
		        next_pe <= '0';
                timer_rst <= '0';
				next_bit <= dout_sipo_local; -- CHECK!
                if((count <= relax_margin) and (fall = '1')) then
					next_state <= receive1;
                    timer_rst <= '1';
                elsif ((count <= relax_margin) and (fall = '0')) then 
                    next_state <= dhtdrive2;
                else
					next_state <= idle;
					next_pe <= '1';
				end if;
            when receive1 => 
                    next_pe <= '0';
                    timer_rst <= '0';
				    next_bit <= dout_sipo_local; -- CHECK!
                if (shift_count = 40) then
                    next_state <= idle;

				elsif((count <= relax_margin) and (rise = '1')) then
					next_state <= receive2;
                    timer_rst <= '1';
                elsif ((count <= relax_margin) and (rise = '0')) then
                    next_state <= receive1;
                else
                    next_state <= idle;
					next_pe <= '1';
				end if;
			when receive2 =>
                timer_rst <= '0';
                next_pe <= '0';
				next_bit <= dout_sipo_local; -- CHECK!
				if((count < 50) and (fall  = '1')) then
                    timer_rst <= '1';
					next_bit <= '0';
					next_state <= receive1;
				elsif((count >= 50) and (fall = '1')) then
                    timer_rst <= '1';
					next_bit <= '1';
					next_state <= receive1;
                elsif((count <= relax_margin) and (fall = '0')) then
                               next_state <= receive2;
                else
					next_state <= idle;
					next_pe <= '1';
				end if;
			end case;
	end process;
end architecture arc;
