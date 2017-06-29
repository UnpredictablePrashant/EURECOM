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
	type state_type is (INIT, IDLE, WAIT_START, SEND_START, LISTEN, DHT_INIT, DHT_RESPONSE, ACQ, DETECT_BIT);
	signal ps, ns: state_type; 
	signal shift_local: std_ulogic;
	signal pe_local: std_ulogic;
	signal busy_local: std_ulogic;
	signal data_drv_local: std_ulogic;
	signal timeout_local: positive;
	--	signal bitc: std_logic_vector;
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
			    busy <= '1';
				-- dsi is by default set to 0 in comb process but value taken into consideration only when shift asserted
			else
				ps <= ns;
				pe <= pe_local;
			    busy <= busy_local;
		        data_drv <= data_drv_local;
			    timeout <= timeout_local;
			    shift <= shift_local;
			    if (ps /= ns) then
				    fsm_reset <= '1';
			    else
				    fsm_reset <= '0';
				end if;
			end if;
		end if;
	end process sync_process;

	comb_process: process(ps,beg,pulse,dsensor)
	    variable cpt: natural := 0;
	    variable first: std_ulogic := '1';
	begin
		-- solution of the teacher to not use each time an else do this ns <= ps; need to be sure that it is assigned no matter what so default value;
		ns <= ps;
		shift_local <= '0';
		--By default it will be 1us to be sure that no strange result will happen in the timer
		timeout_local <= 1; 
		busy_local <= '0';
		dsi <= '0';
		data_drv_local <= '0';
		case ps is
			when INIT =>
			    first := '1';
				ns <= IDLE;
				pe_local <= '0';
			--TODO Need to take into account reseting for eg cpt
			when IDLE =>
			    cpt := 0;
				if (first = '0') then
					ns <= SEND_START;
				else 
					ns <= WAIT_START;
					first := '0';
				end if; 
			when WAIT_START =>       
			    timeout_local <= 1000000;
			    busy_local <= '1';
				if (pulse = '1' and beg = '1') then
					ns <= SEND_START;
				end if;
			when SEND_START =>   
			    busy_local <= '0';
			    timeout_local <= 20000;
				if (pulse = '1') then 
					ns <= LISTEN;
				end if;
			when LISTEN =>
			    pe_local <= '0';
			    timeout_local <= 50;
				if (dsensor = '0' and pulse = '0') then
					ns <= DHT_INIT;
				elsif (pulse = '1' and (dsensor = '0' or dsensor = '1')) then
				    ns <= IDLE;
				    pe_local <= '1';
				end if;
			when DHT_INIT =>    
			    timeout_local <= 100;
			    data_drv_local <= '1';
				if (dsensor = '1' and pulse = '0') then
					ns <= DHT_RESPONSE;
				elsif (dsensor = '0' and (pulse = '1' or dsensor = '1')) then
					ns <= IDLE;
					pe_local <= '1';
				end if; 
			when DHT_RESPONSE =>
			    timeout_local <= 100;
			    data_drv_local <= '0';
				if (dsensor = '0' and pulse = '0' ) then
					ns <= ACQ;
				elsif (pulse = '1' and dsensor = '1') then
					ns <= IDLE;
					pe_local <= '1';
				end if;
			when ACQ =>
			    timeout_local <= 60;
				if (pulse = '0' and dsensor = '1') then
					ns <= DETECT_BIT;
				elsif (dsensor = '0' and cpt >= 40) then
					ns <= IDLE;
				elsif (dsensor = '0' and pulse = '1') then
				    ns <= IDLE;
				    pe_local <= '1';
				end if;
			when DETECT_BIT => 
			    timeout_local <= 50; 
				if (pulse = '1' ) then
				    dsi <= dsensor; 
			        shift_local <= '1';
					ns <= ACQ;
					cpt := cpt + 1; 
				end if;
			
		end case;
	end process comb_process;
		
end architecture arc;

