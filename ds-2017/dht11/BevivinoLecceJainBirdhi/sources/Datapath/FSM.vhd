LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FSM IS
PORT(
	clk:in std_ulogic;
	rstsn_checker_value:out std_ulogic;
	rstsn_counter:out std_ulogic;
	rstsn_display:out std_ulogic;
	rstsn_sr:out std_ulogic;
	rstsn_checksum:out std_ulogic;
	rstsn_sampler:out std_ulogic;
	RST_EXT:in std_ulogic;
	check_80us:out std_ulogic;
	check_70us:out std_ulogic;
	check_50us:out std_ulogic;
	check_20_40us:out std_ulogic;
	check_26_28us:out std_ulogic;
	ack_80us:in std_ulogic;
	ack_70us:in std_ulogic;
	ack_50us:in std_ulogic;
	ack_20_40us:in std_ulogic;	
	ack_26_28us:in std_ulogic;
	count_18ms:out std_ulogic;
	finish_18ms:in std_ulogic;
	count_23ms:out std_ulogic;
	busy:out std_ulogic;
	prot_err:out std_ulogic;
	shift_sr:out std_ulogic;
	rdy_meas:in std_ulogic;
	start_sampler:out std_ulogic;
	start_process:in std_ulogic;
	data_drv:out std_ulogic;
	input_shift:out std_ulogic;
	stati:out std_logic_vector(4 downto 0)

);
END FSM;

ARCHITECTURE behave of FSM IS
	TYPE Status IS 	(
	IDLE,			--00000
	STARTING_PROCESS,	--00001
	WAIT18MS,		--00010
	START_SAMPLER0,		--00011
	CHECK_20_40US_ON,	--00100
	CHECK_20_40US_OFF,	--00101
	RST_BEFORE_SAMPL1,	--00110
	START_SAMPLER1,		--00111
	CHECK_80US_ON_FIRST,	--01000
	CHECK_80US_OFF_FIRST,	--01001
	PROTOCOL_ERROR,		--01010
	RST_BEFORE_SAMPL2,	--01011
	START_SAMPLER2,		--01100
	CHECK_80US_ON_SECOND,	--01101
	CHECK_80US_OFF_SECOND,	--01110
	RST_BEFORE_SAMPL3,	--01111
	START_SAMPLER3,		--10000
	SET_INDEX,		--10001
	CHECK_50US_ON,		--10010
	CHECK_50US_OFF,		--10011
	RST_BEFORE_SAMPL4,	--10100
	START_SAMPLER4,		--10101
	RST_BEFORE_SAMPL5,	--10110
	START_SAMPLER5,		--10111
	CHECK_ONE_ZERO_ON,	--11000
	CHECK_ONE_ZERO_OFF,	--11001
	SHIFT_ONE,		--11010
	SHIFT_ZERO,		--11011
	STOP_SHIFT,		--11100
	INCREMENT_INDEX,	--11101
	DATA_READY);		--11110
	SIGNAL current_state, next_state : Status;
	SIGNAL index: integer range 0 to 40;
	SIGNAL inc_index: std_ulogic;
	SIGNAL rst_inc_index: std_ulogic;
	SIGNAL coded_states: std_logic_vector(4 downto 0):="00000";
	
BEGIN
	
stati <=coded_states;
NEXT_STATE_GENERATION:
	PROCESS(current_state, RST_EXT,start_process,finish_18ms,index,rdy_meas,ack_20_40us,ack_80us,ack_50us,ack_70us,ack_26_28us)
	BEGIN
		CASE current_state IS 
			
			WHEN IDLE  => 
				IF start_process = '0' THEN next_state <=IDLE ;
				ELSE next_state <= STARTING_PROCESS;
				END IF;
			
			WHEN STARTING_PROCESS => 
				next_state <= WAIT18MS;
			
			WHEN WAIT18MS  => 
				IF finish_18ms = '0' THEN next_state <=WAIT18MS ;
				ELSE next_state <= START_SAMPLER0;
				END IF;

			WHEN START_SAMPLER0  => 
				IF rdy_meas = '0' THEN next_state <=START_SAMPLER0 ;
				ELSE next_state <= CHECK_20_40US_ON;
				END IF;
			
			WHEN CHECK_20_40US_ON => 
				next_state <= CHECK_20_40US_OFF;

			WHEN CHECK_20_40US_OFF  => 
				IF ack_20_40us = '0' THEN next_state <=PROTOCOL_ERROR ;
				ELSE next_state <= RST_BEFORE_SAMPL1;
				END IF;

			WHEN RST_BEFORE_SAMPL1 => 
				next_state <= START_SAMPLER1;

			WHEN START_SAMPLER1  => 
				IF rdy_meas = '0' THEN next_state <=START_SAMPLER1 ;
				ELSE next_state <= CHECK_80US_ON_FIRST;
				END IF;

			WHEN CHECK_80US_ON_FIRST => 
				next_state <= CHECK_80US_OFF_FIRST;

			WHEN CHECK_80US_OFF_FIRST  => 
				IF ack_80us = '0' THEN next_state <=PROTOCOL_ERROR ;
				ELSE next_state <= RST_BEFORE_SAMPL2;
				END IF;
			
			WHEN RST_BEFORE_SAMPL2 => 
				next_state <= START_SAMPLER2;
			
			WHEN START_SAMPLER2  => 
				IF rdy_meas = '0' THEN next_state <=START_SAMPLER2 ;
				ELSE next_state <= CHECK_80US_ON_SECOND;
				END IF;

			WHEN CHECK_80US_ON_SECOND => 
				next_state <= CHECK_80US_OFF_SECOND;
			
			WHEN CHECK_80US_OFF_SECOND  => 
				IF ack_80us = '0' THEN next_state <=PROTOCOL_ERROR ;
				ELSE next_state <= RST_BEFORE_SAMPL3;
				END IF;

			WHEN RST_BEFORE_SAMPL3 => 
				next_state <= START_SAMPLER3;

			WHEN START_SAMPLER3  => 
				IF rdy_meas = '0' THEN next_state <=START_SAMPLER3 ;
				ELSE next_state <= SET_INDEX;
				END IF;

			WHEN SET_INDEX => 
				next_state <= CHECK_50US_ON;

			WHEN CHECK_50US_ON => 
				next_state <= CHECK_50US_OFF;

			WHEN CHECK_50US_OFF  => 
				IF ack_50us = '0' THEN next_state <=PROTOCOL_ERROR ;
				ELSE next_state <= RST_BEFORE_SAMPL4;
				END IF;
			
			WHEN RST_BEFORE_SAMPL4 => 
				next_state <= START_SAMPLER4;

			WHEN START_SAMPLER4  => 
				IF rdy_meas = '0' THEN next_state <=START_SAMPLER4 ;
				ELSE next_state <= CHECK_ONE_ZERO_ON;
				END IF;

			WHEN CHECK_ONE_ZERO_ON => 
				next_state <= CHECK_ONE_ZERO_OFF;

			WHEN CHECK_ONE_ZERO_OFF  => 
				IF ack_70us = '1' THEN next_state <= SHIFT_ONE ;
				ELSIF ack_26_28us ='1' THEN next_state <= SHIFT_ZERO ;
				ELSE next_state <= PROTOCOL_ERROR;
				END IF;
			
			WHEN SHIFT_ONE => 
				next_state <= STOP_SHIFT;

			WHEN SHIFT_ZERO => 
				next_state <= STOP_SHIFT;

			WHEN STOP_SHIFT => 
				next_state <= INCREMENT_INDEX;

			WHEN INCREMENT_INDEX => 
				IF index < 39 THEN next_state <= RST_BEFORE_SAMPL5;
				ELSE next_state <= DATA_READY;
				END IF;

			WHEN RST_BEFORE_SAMPL5 => 
				next_state <= START_SAMPLER5;

			WHEN START_SAMPLER5  => 
				IF rdy_meas = '0' THEN next_state <=START_SAMPLER5 ;
				ELSE next_state <= CHECK_50US_ON;
				END IF;

			WHEN DATA_READY => 
				IF RST_EXT = '1' THEN next_state <= IDLE;
				ELSIF start_process = '1' THEN next_state <= STARTING_PROCESS;
				ELSE next_state <= DATA_READY;
				END IF;
			
			WHEN PROTOCOL_ERROR => 
				IF start_process = '0' THEN next_state <= PROTOCOL_ERROR;
				ELSE next_state <= STARTING_PROCESS;
				END IF;


			WHEN OTHERS => 
				next_state <= IDLE;
		END CASE;	
	END PROCESS NEXT_STATE_GENERATION;
	

CURRENT_STATE_UPDATING:
	PROCESS(clk)
	BEGIN
		IF RISING_EDGE(clk)  THEN
			IF RST_EXT='1' THEN
				current_state<=IDLE;
				index<=0;
			ELSE
				IF rst_inc_index='0' THEN
					index<=0;
				ELSE
					IF inc_index='1' THEN
						index<=index+1;
					END IF;
				END IF;
				current_state<=next_state;
			END IF;
		END IF;
	END PROCESS CURRENT_STATE_UPDATING;

	
OUTPUT_GENERATION:
	PROCESS(current_state,index)
	BEGIN
		rstsn_checker_value	<= '0';
		rstsn_counter		<= '0';
		rstsn_display		<= '0';
		rstsn_sr		<= '0';
		rstsn_checksum		<= '0';
		rstsn_sampler		<= '0';
		check_80us		<= '0';
		check_70us		<= '0';
		check_50us		<= '0';
		check_20_40us		<= '0';
		check_26_28us		<= '0';
		count_18ms		<= '0';
		count_23ms		<= '0';
		busy			<= '0';
		prot_err		<= '0';
		shift_sr		<= '0';
		start_sampler		<= '0';
		data_drv		<= '0';
		input_shift		<= '0';
		rst_inc_index		<= '0';
		inc_index		<= '0';
		
		CASE current_state IS 
			WHEN IDLE => 
				coded_states 		<= "00000";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '0';
				rstsn_sr		<= '0';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '0';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN STARTING_PROCESS => 
				coded_states 		<= "00001";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '1';
				rstsn_display		<= '1';
				rstsn_sr		<= '0';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '1';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '1';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN WAIT18MS => 
				coded_states 		<= "00010";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '1';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '1';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN START_SAMPLER0 => 
				coded_states 		<= "00011";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN CHECK_20_40US_ON => 
				coded_states 		<= "00100";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '1';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN CHECK_20_40US_OFF => 
				coded_states 		<= "00101";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN RST_BEFORE_SAMPL1 => 
				coded_states 		<= "00110";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN START_SAMPLER1 => 
				coded_states 		<= "00111";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN CHECK_80US_ON_FIRST => 
				coded_states 		<= "01000";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '1';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN CHECK_80US_OFF_FIRST => 
				coded_states 		<= "01001";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN RST_BEFORE_SAMPL2 => 
				coded_states 		<= "01011";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN START_SAMPLER2 => 
				coded_states 		<= "01100";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN CHECK_80US_ON_SECOND => 
				coded_states 		<= "01101";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '1';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN CHECK_80US_OFF_SECOND => 
				coded_states 		<= "01110";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN RST_BEFORE_SAMPL3 => 
				coded_states 		<= "01111";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN START_SAMPLER3 => 
				coded_states 		<= "10000";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';
				
			WHEN SET_INDEX =>
				coded_states 		<= "10001";
				rst_inc_index		<= '1';
				busy			<= '1';
				inc_index		<= '0';

			WHEN CHECK_50US_ON => 
				coded_states 		<= "10010";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '1';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN CHECK_50US_OFF => 
				coded_states 		<= "10011";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN RST_BEFORE_SAMPL4 => 
				coded_states 		<= "10100";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN START_SAMPLER5 => 
				coded_states 		<= "10111";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';
	
			WHEN RST_BEFORE_SAMPL5 => 
				coded_states 		<= "10110";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				rst_inc_index		<= '1';	
				inc_index		<= '0';

			WHEN START_SAMPLER4 => 
				coded_states 		<= "10101";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN CHECK_ONE_ZERO_ON => 
				coded_states 		<= "11000";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '1';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '1';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN CHECK_ONE_ZERO_OFF => 
				coded_states 		<= "11001";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN SHIFT_ONE => 
				coded_states 		<= "11010";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '1';
				start_sampler		<= '1';
				data_drv		<= '0';
				input_shift		<= '1';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN SHIFT_ZERO => 
				coded_states 		<= "11011";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '1';
				start_sampler		<= '1';
				data_drv		<= '0';
				input_shift		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';

			WHEN STOP_SHIFT =>
				coded_states 		<= "11100";
				rstsn_checker_value	<= '1';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				input_shift		<= '0';
				rst_inc_index		<= '1';
				inc_index		<= '0';
			
			WHEN INCREMENT_INDEX =>
				coded_states 		<= "11101";
				inc_index		<= '1';
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '1';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '1';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '1';
				data_drv		<= '0';
				input_shift		<= '0';
				rst_inc_index		<= '1';

			
			WHEN DATA_READY => 
 				coded_states 		<= "11110";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '0';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '1';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '0';
				prot_err		<= '0';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				input_shift		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			WHEN PROTOCOL_ERROR => 
				coded_states 		<= "01010";
				rstsn_checker_value	<= '0';
				rstsn_counter		<= '1';
				rstsn_display		<= '1';
				rstsn_sr		<= '1';
				rstsn_checksum		<= '0';
				rstsn_sampler		<= '0';
				check_80us		<= '0';
				check_70us		<= '0';
				check_50us		<= '0';
				check_20_40us		<= '0';
				check_26_28us		<= '0';
				count_18ms		<= '0';
				count_23ms		<= '0';
				busy			<= '0';
				prot_err		<= '1';
				shift_sr		<= '0';
				start_sampler		<= '0';
				data_drv		<= '0';
				input_shift		<= '0';
				rst_inc_index		<= '0';
				inc_index		<= '0';

			




		END CASE;	
	END PROCESS OUTPUT_GENERATION;
	
	
END behave;
