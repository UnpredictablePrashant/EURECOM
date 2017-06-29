-- DTH11 controller
library ieee;
use ieee.std_logic_1164.all;
use work.dht11_pkg.all;
use ieee.numeric_std.all;

-- Read data (do) format:
-- do(39 downto 24): relative humidity (do(39) = MSB)
-- do(23 downto 8):  temperature (do(23) = MSB)
-- do(7 downto 0):   check-sum = (do(39 downto 32)+do(31 downto 24)+do(23 downto 16)+do(15 downto 8)) mod 256

entity dht11_ctrl is
  generic(
  freq:    positive range 1 to 1000 -- Clock frequency (MHz)
);

port(
      clk:      in  std_ulogic;
      srstn:    in  std_ulogic; -- Active low synchronous reset
      start:    in  std_ulogic;
      data_in:  in  std_ulogic;
      data_drv: out std_ulogic;
      pe:       out std_ulogic; -- Protocol error
      b:        out std_ulogic; -- Busy
      do:       out std_ulogic_vector(39 downto 0) -- Read data
    );
end entity dht11_ctrl;


architecture rtl of dht11_ctrl is
  signal global_reset : std_ulogic; -- reset all the processes 
  
  -- Signal used to start an acquisition
  type states_start is (WAITING,SENDING0,SENDING0_START,SENDING1,READING0,READING1); -- states of the process START
  
  -- Signal used to read --
  type states_read_bit is (WAITING,COUNTING0,COUNTING1);
  type states_read_message is (WAITING,READING_MESSAGE,READING_END_TRANSMISSION);
  signal start_read : std_ulogic;          -- to start receiving the sensor's message
  signal start_read_bit : std_ulogic;      -- to start the reading of one bit of the message
  signal bit_read : std_ulogic;            -- contains the last bit read by the interface
  
  -- Signal used to store data --
  signal do_tmp: std_ulogic_vector(39 downto 0); -- output of the shift register.
  signal s_add_read_bit : std_ulogic;            -- synchronous signal that will save in the register the value of the read bit 
  signal s_update_do: std_ulogic;                -- tells if do has to be updated
  
  -- Counter
  signal count : integer := 0;             -- contains the number of us elapsed since the last reset of the counter
  signal pulse : std_ulogic;               -- timer signal
  signal s_reset_count_n : std_ulogic;     -- to reset the counter process, active low
  signal s_reset_count_start : std_ulogic; -- to reset the counter from the process START
  signal s_reset_count_read_message : std_ulogic;  -- to reset the counter from READ_MESSAGE
  signal s_reset_count_read : std_ulogic;  -- to reset the counter from READ_BIT
  
  -- Error and busy signals -- 
  signal busy: std_ulogic;  -- tells if the sensor is busy (powerup, start, reading)
  signal busy_powerup: std_ulogic; -- tells if the 1s delay is passed or not
  signal busy_start: std_ulogic; -- tells if the START_PROCESS is running
  signal busy_reading_message : std_ulogic; -- tells if the controller is receiving data
  signal busy_reading_bit : std_ulogic; -- tell if the controller is receiving one bit
  signal PE_start : std_ulogic; -- PE during START_PROCESS
  signal PE_read : std_ulogic; -- PE during READ_BIT process
  signal PE_read_message : std_ulogic; -- PE during READ_MESSAGE process
  signal PE_tmp: std_ulogic; -- to use PE as an input also

begin
  -- SHIFT REGISTER --
  shift_reg: entity work.sr(arc)
  port map (
             clk => clk,
             sresetn => srstn,
             di => bit_read,
             do => do_tmp,
             shift => s_add_read_bit
           );
  -- TIMER --
  timer0 : entity work.timer(arc)
  generic map(
               freq => freq
             )
  port map(
            clk => clk,
            sresetn => srstn, 
            pulse => pulse
          );

  s_reset_count_n <= not(s_reset_count_read or s_reset_count_start or global_reset or s_reset_count_read_message);
  PE_tmp <= PE_start or PE_read or PE_read_message;
  PE <= PE_tmp;
  busy <= busy_reading_bit or busy_reading_message or busy_powerup or busy_start;
  b <= busy;
  global_reset <= not srstn;

  POWERUP_DELAY: process(clk)
    variable tmp: bit := '0';
  begin
    if rising_edge(clk) then
      if global_reset = '1' then
        tmp := '0';
        busy_powerup <= '0';
      elsif tmp = '0' then
        if count >= dht11_reset_to_start_min then
          busy_powerup <= '0';
          tmp := '1';
        else
          busy_powerup <= '1';
        end if;
      else -- tmp =1
          busy_powerup <= '0';
      end if;
    end if;
  end process POWERUP_DELAY;

  START_PROCESS: process(clk)
    variable state: states_start := WAITING;
  begin
    if rising_edge(clk) then 
      if global_reset = '1' then    -- reset the process
        state := WAITING;           -- go to state waiting
        busy_start <= '0';
        data_drv <= '0'; 
        s_reset_count_start <= '0';
        PE_start <= '0';
        start_read <= '0';
      else
        s_reset_count_start <= '0';
        data_drv <= '0';
        start_read <= '0';
        if state=WAITING then        -- state in which the process wait for the start signal
          if busy= '0' and start= '1' then -- if not busy and start signal set
            -- report "Sending0";
            PE_start <= '0';            -- reset PE_start to 0 
            busy_start <= '1'; 
            state := SENDING0_START;          -- switch to state SENDING0 
            s_reset_count_start <= '1'; -- reset the counter
          else                          -- default case in WAITING state
            busy_start <= '0';
            -- if data_in = '0' and busy='0' then
            -- PE_start <= '1';     -- we removed this PE to simplify our controller for synthesis
            -- end if;
          end if;
        elsif state=SENDING0_START then    -- to let the counter have the time to reset
          state := SENDING0;
          data_drv <= '1';            -- take the control of the connection
        elsif state=SENDING0 then       -- state in which the process send '0' to the sensor for 18 ms
          if count >= dht11_start_duration_min + 1800 then     -- wait 18ms before sending 1
            -- report "Sending1";
            state := SENDING1;          -- switch to state SENDING1
            data_drv <= '0';            -- release the control of the connection 
            s_reset_count_start <= '1'; -- reset the counter
          else                          -- default case during SENDING0 state  
            data_drv <= '1';            -- keep the control of the connection
          end if;
        elsif state=SENDING1 then       -- state in wich the process send '1' to the sensor for 20-40us
          if data_in='0' then           -- when the DHT set the wire to 0, switch to READING0
            if not (count <= 50) then 
              -- report "PE during sending1, 1 doesn't last the right time, count:" & to_string(count) & "instead of " & to_string(dht11_start_to_ack_max);
              PE_start <= '1';
            -- else
              -- report "reading0";
            end if;
            state := READING0;
            s_reset_count_start <= '1'; -- reset the counter
          --elsif count > dht11_start_to_ack_max + 5 then
          --  PE_start <= '1';          -- we removed this PE to simplify our controller for synthesis
          end if;
        elsif state=READING0 then       -- state in which the sensor should set the wire on 0 for 80us
          if data_in = '1' then         -- end of the state READING0, the wire has been set to 1
            if not (count <= 100)  then -- if the wire has been to 0 for 80 us it is ok, if not: PE_start
              -- report "PE in reading0, 0 doesn't last the right time, count:" & to_string(count) & "instead of " & to_string(dht11_ack_duration);
              PE_start <= '1';          -- Protocol error
            -- elsif PE_start = '0' then
              -- report "reading1";
            end if;
            state := READING1;              -- switch to state READING1
            s_reset_count_start <= '1';     -- reset the counter
          --elsif count > dht11_ack_duration + 5 then
          --  PE_start <= '1';              -- we removed this PE to simplify our controller for synthesis
          end if;
        elsif state=READING1 then             -- state in which the sensor should set the wire on 1 for 80us
          if data_in='0' then                 -- end of state READING1, the wire has been set to 0
            if not (count <= 100) then        -- data_in should be set to 1 for 80 us
              -- report "PE in reading1, 1 doesn't last the right time, count:" & to_string(count) & "instead of " & to_string(dht11_ack_to_bit);
              PE_start <= '1';                -- Protocol error
            -- elsif PE_start = '0' then
              -- report "start read the message";
            end if ;
            start_read <= '1';              -- we start reading the message sent by the sensor
            s_reset_count_start <= '1';
            state := WAITING;               -- move to WAITING state in any case 
            -- elsif count > dht11_ack_to_bit + 5 then  -- if data_in is not reset to 0 before 82 us there is a PE_start
              --   PE_start <= '1';
          end if; 
        end if ;  -- end switch case on the states
      end if ;    -- end if reset
    end if ;      -- end if rising edge
  end process START_PROCESS;

  COUNTER: process(clk, s_reset_count_n)
  begin
    if clk'event and clk = '1' then
      if s_reset_count_n = '0' then
        count <= 0;          -- reset the counter
    elsif pulse = '1' then   -- pulse is active each us
        count <= count + 1;  -- counting the us
      end if;
    end if;
  end process COUNTER;


  READ_BIT: process(clk) -- Process that will read one bit at a time
    variable state: states_read_bit := WAITING;
  begin
    if rising_edge(clk) then         -- Only on the rising edge of the clock
      if global_reset = '1' then     -- reset all the outputs and the state
        state := WAITING;
        busy_reading_bit <= '0';
        bit_read <= '0';
        s_add_read_bit <= '0';
        s_reset_count_read <= '0'; 
        PE_read <= '0';
      else
        s_reset_count_read <= '0';     -- to make the reset only last one clock period
        s_add_read_bit <= '0';         -- to make the reset only last on clock cycle
        busy_reading_bit <= '1';       -- always reading except in waiting state
        if state=WAITING then          -- when the process is waiting
          if (start_read_bit='1') then -- when start_read_bit is set by read_message we change state
            state := COUNTING0;        -- change the state to COUNTING0
            PE_read <= '0';            -- no protocol error at the beginning of the read
          else                         -- default case of the waiting state
            busy_reading_bit <= '0';   -- tell the other processes that the process is not reading
          end if;
        elsif state=COUNTING0 then     -- state when when data_in is 0 for 50 us
          if data_in = '1' then        -- when data_in changes to 1 we check for count
              if not (count <= 75) then    -- normal case count=50us (PE if > 50 + margin)
              -- report "PE during counting0, 0 doesn't last the rigth time, count:" & to_string(count) & " instead of :" & to_string(dht11_bit_duration);
              PE_read <= '1';          -- set the PE_read bit
            end if;
            state := COUNTING1;        -- change the state to COUNTING1
            s_reset_count_read <= '1'; -- start the counter
          --elsif count > dht11_bit_duration then
          --  PE_read <= '1';          -- we removed this PE to simplify our controller for synthesis
          end if ;
        elsif state=COUNTING1 then     -- state COUNTING1 is the state when data_in is 1
          if data_in = '0' then        -- when data_in changes to 0 we check for count
            if (count <= 50) then     -- if data_in is set to 1 for 26-28 us it is an 0 (with margin)
              bit_read <= '0';         -- set the bit read to 1
              s_add_read_bit <= '1';   -- add the bit read to the 40 bits shift register
            elsif (count <= 100) then -- if data_in is set to 1 for 70 us it is an 0 (with margin)
              bit_read <= '1';         -- set the bit read to 1
              s_add_read_bit <= '1';   -- add the bit read to the 40 bits shift register
            else                       -- else there was a protocol error
              -- report "PE don't know if 0 or 1, count:" & to_string(count) & " instead of " & to_string(dht11_bit1_to_next) & " or " & to_string(dht11_bit0_to_next_min+5);
              PE_read <= '1';
              bit_read <= '0';         -- dummy value
              s_add_read_bit <= '1';   -- just to make the read message process finish
            end if;
            state := WAITING;          -- in any case we switch to WAITING state
          --elsif count > dht11_bit1_to_next + 5 then -- PE
          --  PE_read <= '1';          -- we removed this PE to simplify our controller for synthesis
          end if; -- data_in=0
        end if; -- state
      end if; -- reset
    end if; -- clk
  end process READ_BIT;

  READ_MESSAGE: process(clk)
    variable bit_index: integer := 0;
    variable state : states_read_message := WAITING;
  begin
    if rising_edge(clk) then          -- Only on the rising edge of the clock
      if global_reset = '1' then
        busy_reading_message <= '0';
        start_read_bit <= '0';
        s_reset_count_read_message <= '0';
        PE_read_message <= '0';
        s_update_do <= '0';
        state := WAITING;
        bit_index := 0;
      else 
        start_read_bit <= '0';             -- default value of all states
        s_reset_count_read_message <= '0'; -- default value of all states
        s_update_do <= '0';                -- default value of all states
        busy_reading_message <= '1';       -- always reading except in waiting state
        if state = WAITING then
          if start_read = '1' then         -- want the process is called, we start reading the message
            state := READING_MESSAGE;
            PE_read_message <= '0';        -- no PE at the beginning at the beginning
            start_read_bit <= '1';         -- start the process that will read a bit of the message
          else
            bit_index := 0;                -- reset bit_index when waiting
            busy_reading_message <= '0';   -- not running when waiting 
          end if;
        elsif state = READING_MESSAGE then  -- it is reading a message
          if s_add_read_bit = '1' then -- the proccess reading a bit has finished reading the previous bit
            if PE_read = '1' then      -- if a PE error happens during the reading of a bit, we have a PE during reading message
              PE_read_message <= '1';
            elsif PE_read_message = '0' then        -- if no PE at this point, print the bit read
              -- report "bit index:" & to_string(bit_index) & " bit read:" & to_string(bit_read);
            end if;
            bit_index := bit_index + 1; -- increments the number of bits of the message read
            if bit_index <= 39 then     -- if there are still some bits to read
              start_read_bit <= '1';    -- start the process that will read a bit of the message
              s_reset_count_read_message <= '1'; -- reset the counter
            else      -- this is the last bit to read !
              bit_index := 0;           -- we reset the number of bits read
              s_reset_count_read_message <= '1'; -- reset the counter
              state := READING_END_TRANSMISSION; -- go to the next state
            end if; -- if bit_index<=39
          end if; -- if add_bit=1
        elsif state = READING_END_TRANSMISSION then 
          if data_in = '1' then -- when the DATA bus voltage is freed
            if not (count<=dht11_bit_duration+25) then -- 0 should last 50 us
              -- report "PE end transmission phase, count: " & to_string(count) & " instead of " & to_string(dht11_bit_duration) ;
              PE_read_message <= '1';
            elsif PE_tmp = '0' then 
              -- report "finish reading message";
              s_update_do <= '1';
            end if;
            s_update_do <= '1';   -- do should not be updated here, but we wanted to see the values measured on the Zybo, even if they were wrong
            busy_reading_message <= '0';
            state := WAITING;
          -- elsif count>dht11_bit_duration+5 then --PE  
          --   PE_read_message <= '1';          -- we removed this PE to simplify our controller for synthesis
          end if; -- if data_in=1 or count too big
        end if; -- state
      end if; -- reset
    end if; -- clk
  end process READ_MESSAGE;

  UPDATE_DATA: process(clk)
  begin
    if rising_edge(clk) then
      if global_reset = '1' then
        do <= (others => '0');
      elsif s_update_do ='1' then
        do <= do_tmp;
      end if ;
    end if;
  end process UPDATE_DATA;


end architecture rtl;
