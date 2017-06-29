library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
entity fsm is 
	port(
		clk: in std_ulogic;
		beg: in std_ulogic;
		sresetn: in std_ulogic;
		dsensor: in std_ulogic;
		pulse: in std_ulogic;
		data_drv: out std_ulogic;
		fsm_reset: out std_ulogic;
		pe: out std_ulogic;
		busy: out std_ulogic;
		timeout: out positive;
		shift: out std_ulogic;
		dsi: out std_ulogic
	);
end entity fsm;

architecture arc of fsm is
	type state_type is (INIT, IDLE, WAIT_START, SEND_START, LISTEN, DHT_INIT, DHT_RESPONSE, ACQ, DETECT_BIT, TRANSITION_STATE);
	signal ps, ns: state_type; 
	signal shift_local,dsi_local: std_ulogic;
	signal pe_local: std_ulogic;
	signal busy_local: std_ulogic;
	signal data_drv_local: std_ulogic;
	signal timeout_local: positive;
	--	signal bitc: std_logic_vector;
	signal saved_ns: state_type := IDLE;
	signal saved_ps: state_type := IDLE;
	signal first,first_local: std_ulogic;
begin

--	up <= '1' when ps = RUN else '0' ;--up is enabled only when state machine is in run mode

	sync_process: process(clk)
	begin
		if rising_edge(clk) then
		
			if sresetn = '0' then
				ps <= INIT;
				pe <= '0';
				fsm_reset <= '1';
				timeout <= 1;
				data_drv <= '0';
				shift <= '0';
				first <= '1';
		        busy <= '1';
				dsi <= '0';
			else
				pe <= pe_local;
			    busy <= busy_local;
	            data_drv <= data_drv_local;
			    timeout <= timeout_local;
			    shift <= shift_local;
			    if (ns = TRANSITION_STATE) then
				    fsm_reset <= '1';
			    else
				    fsm_reset <= '0';
				end if;
				ps <= ns;
				saved_ps <= saved_ns;
				first <= first_local;
				dsi <= dsi_local;
			end if;
		end if;
	end process sync_process;

	comb_process: process(ps,beg,pulse,dsensor)
	    variable cpt: natural := 0;
	   
	begin
		-- solution of the teacher to not use each time an else do this saved_ns <= ps; need to be sure that it is assigned no matter what so default value;
		ns <= ps;
		shift_local <= '0';
		busy_local <= '0';
		dsi_local <= '0';
		data_drv_local <= '0';
		case ps is
			when TRANSITION_STATE =>
				ns <= saved_ps;
				if ( data_drv = '1') then
					data_drv_local <= '1';
				end if;
			when INIT => 
				saved_ns <= IDLE;
				ns <= TRANSITION_STATE;
				pe_local <= '0';
			--TODO Need to take into account reseting for eg cpt
			when IDLE =>
			    cpt := 0;
				ns <= TRANSITION_STATE;
				data_drv_local <= '1';
				if (first = '0') then
					saved_ns <= SEND_START;
				else 
					saved_ns <= WAIT_START;
			  		first_local <= '0';
					timeout_local <= 1000000;
				end if; 
			when WAIT_START =>       
			    busy_local <= '1';
				if (pulse = '1' and beg = '1') then
					saved_ns <= SEND_START;
			   		timeout_local <= 20000;
					ns <= TRANSITION_STATE;
				end if;
			when SEND_START =>   
		        busy_local <= '0';
			    if (pulse = '1') then 
				ns <= TRANSITION_STATE;
				saved_ns <= LISTEN;
			        timeout_local <= 50;
			    end if;
			when LISTEN =>
			    pe_local <= '0';
			    if (dsensor = '0' and pulse = '0') then
					saved_ns <= DHT_INIT;
					ns <= TRANSITION_STATE;
			                timeout_local <= 100;
			    elsif (pulse = '1' and (dsensor = '0' or dsensor = '1')) then
				 	saved_ns <= IDLE;
					ns <= TRANSITION_STATE;
				    	pe_local <= '1';
			    end if;
			when DHT_INIT =>    
			    data_drv_local <= '1';
		   	    if (dsensor = '1' and pulse = '0') then
				saved_ns <= DHT_RESPONSE;
				ns <= TRANSITION_STATE;
			    	timeout_local <= 100;
			    elsif (dsensor = '0' and (pulse = '1' or dsensor = '1')) then
				saved_ns <= IDLE;
				ns <= TRANSITION_STATE;
				pe_local <= '1';
			    end if; 
			when DHT_RESPONSE =>
			        data_drv_local <= '0';
				if (dsensor = '0' and pulse = '0' ) then
					saved_ns <= ACQ;
					ns <= TRANSITION_STATE;
			        timeout_local <= 60;
				elsif (pulse = '1' and dsensor = '1') then
					saved_ns <= IDLE;
					ns <= TRANSITION_STATE;
					pe_local <= '1';
				end if;
			when ACQ =>
				if (pulse = '0' and dsensor = '1') then
					saved_ns <= DETECT_BIT;
					ns <= TRANSITION_STATE;
			    		timeout_local <= 50; 
				elsif (dsensor = '0' and cpt >= 40) then
					saved_ns <= IDLE;
					ns <= TRANSITION_STATE;
				elsif (dsensor = '0' and pulse = '1') then
				    	saved_ns <= IDLE;
					ns <= TRANSITION_STATE;
				    	pe_local <= '1';
				end if;
			when DETECT_BIT => 
				if (pulse = '1' ) then
				 	dsi_local <= dsensor; 
			        shift_local <= '1';
					saved_ns <= ACQ;
					ns <= TRANSITION_STATE;
					cpt := cpt + 1; 
			                timeout_local <= 60;
				end if;
			
		end case;
	end process comb_process;
		
end architecture arc;
