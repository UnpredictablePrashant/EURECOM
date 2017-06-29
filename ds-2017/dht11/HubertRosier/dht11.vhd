library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dht11_top is
  generic(
           freq: integer := 125
         );

  port(
        data:    inout std_logic;
        CLK: in std_ulogic;
        RST: in std_ulogic;
        SW0: in std_ulogic;
        SW1: in std_ulogic;
        SW2: in std_ulogic;
        SW3: in std_ulogic;
        BTN: in std_ulogic;
        LED: out std_ulogic_vector(3 downto 0)
      );

end entity dht11_top;
architecture rtl of dht11_top is
  signal data_in:  std_ulogic;
  signal data_drv: std_ulogic;
  signal s_reset_count_n : std_ulogic;     -- to reset the counter process
  signal count : integer := 0;                  -- contains the number of us elapsed since the last reset of the counter
  signal pulse : std_ulogic;               --
  signal PE_start : std_ulogic;                  -- LED 3, protocol error 
  signal PE_read : std_ulogic;                  -- LED 3, protocol error 
  signal PE : std_ulogic;                  -- LED 3, protocol error 
  signal s_BTN : std_ulogic;               -- synchronous sigal that lasts one cycle after the button has been pressed
  signal global_reset : std_ulogic;               -- reset all the processes 

  -- Signal used to start an acquisition
  type states_start is (WAITING,SENDING0,SENDING1,READING0,READING1); -- states of the process START
  signal s_reset_count_start : std_ulogic;                                    -- to reset the counter from the process START

  -- Signal used to read --
  type states_read_bit is (WAITING,COUNTING0,COUNTING1);
  signal start_read : std_ulogic;          -- to start receiving the sensor's message
  signal start_read_bit : std_ulogic;      -- to start the reading of one bit of the message
  signal bit_read : std_ulogic;            -- contains the last bit read by the interface
  signal s_reset_count_read : std_ulogic;  -- to reset the counter

  -- Signal used to store data --
  signal data_40: std_ulogic_vector(39 downto 0); -- Vector that contains the data received (update when all the bits have been read)
  signal do: std_ulogic_vector(39 downto 0); -- output of the shift register.
  signal s_add_read_bit : std_ulogic;             -- synchronous signal that will save in the register the value of the read bit 
  signal s_reset_data40_n: std_ulogic;            -- to reset the value of the data40

  -- Errors and busy bit -- 
  signal busy: std_ulogic;                 -- the signal that tells if the sensor is sending data or if the 1s delay is passed or not
  signal busy_powerup: std_ulogic;
  signal busy_start: std_ulogic;
  signal reading_message : std_ulogic;     -- signal that tells if the controller is receiving data
  signal reading_bit : std_ulogic;         -- tell if the controller is receiving one bit

  signal CE : std_ulogic; -- Set when checksum error

begin
  shift_reg: entity work.sr(arc)
  port map (
             clk => clk,
             sresetn => s_reset_data40_n,
             di => bit_read,
             do => do,
             shift => s_add_read_bit
           );
  data    <= '0' when data_drv = '1' else 'H';
  data_in <= data;
  PE <= PE_start or PE_read;
  busy <= reading_bit or reading_message or busy_powerup;

  -- TIMER --
  timer0 : entity work.timer(arc)
  generic map(
               freq => freq,
               timeout => 1
             )
  port map(
            clk => CLK, 
            sresetn => s_reset_count_n, -- TODO : Carrefull : active on 0 ! Check we use it correctly
            pulse => pulse
          );

  POWERUP_DELAY: process(clk)
    variable tmp: std_ulogic := '0';
  begin
    if rising_edge(clk) then
      if (global_reset = '1') then
        tmp:='0';
      elsif tmp='0' then
        if count >= 1000000 then
          busy_powerup <= '0';
        else
          busy_powerup <= '1';
        end if;
      else 
        busy_powerup <= '0';
      end if;
    end if;
  end process POWERUP_DELAY;


  START: process(clk)
    variable state: states_start := WAITING;
    variable start_sending0: std_ulogic;
  begin
    if rising_edge(clk) then 
      if global_reset = '1' then    -- reset the process
        state := WAITING;           -- go to state waiting
        s_reset_count_start <= '1'; -- reset the counter
        busy_start <= '0';          --
        start_sending0 := '0';
      else
        s_reset_count_start <= '0';
        if state=WAITING then        -- state in which the process wait for the button to be pressed
          if busy='0' and s_BTN='1' then --  
            report "Sending0";
            busy_start <= '1';          --
            state := SENDING0;          -- switch to state SENDING0 
            start_sending0 := '1';
            data_drv <= '1';            -- take the control of the connection
            data <= '0';                -- set the connection to 0
            s_reset_count_start <= '1'; -- reset the counter
          else                          -- default case in WAITING state
            busy_start <= '0';
            data_drv <= '0';            -- not driving the wire
          end if;
        elsif state=SENDING0 then       -- state in which the process send '0' to the sensor for 18 ms
          if (start_sending0='1') then  -- to let the counter have the time to reset
            start_sending0 := '0';
          else
            if count >= 18 then           -- wait 18us before sending 1
              report "Sending1";
              state := SENDING1;          -- switch to state SENDING1
              data_drv <= '1';            -- keep the control of the connection
              data <= '1';                -- set the value of the wire to 1
              s_reset_count_start <= '1'; -- reset the counter
            else                          -- default case during SENDING0 state  
              data_drv <= '1';            -- keep the control of the connection
              data <= '0';                -- keep the connection to 0
              s_reset_count_start <= '0'; -- to make the reset lasts only 1 clock cycle
            end if;
          end if;
        elsif state=SENDING1 then       -- state in wich the process send '1' to the sensor for 20-40us
          if data_in='0' then            -- when the DHT set the wire to 0, switch to READING0
            if (18 <= count and count <= 42) then
              report "reading0";
              state := READING0;
              data_drv <= '0';            -- release to connection to let the sensor use it
              s_reset_count_start <= '1'; -- reset the counter
            else 
              report "PE during sending1";
              PE_start <= '1';
              state := WAITING;
            end if;
          else
            data_drv <= '0';            -- let the wire go back to 1
            s_reset_count_start <= '0'; -- to make the reset lasts one clock cycle
          end if;
        elsif state=READING0 then       -- state in which the sensor should set the wire on 0 for 80us
          if data_in = '1' then         -- end of the state READING0, the wire has been set to 1
            if 78 <= count and count <= 82 then -- if the wire has been to 0 for 80 us it is ok, if not: PE_start
              state := READING1;              -- switch to state READING1
              s_reset_count_start <= '1';     -- reset the counter
            else 
              report "PE in reading0, 1 doesn't last long enought";
              PE_start <= '1';                      -- Protocol error
              state := WAITING;               -- move to WAITING state in case of PE_start
            end if;
          elsif count > 82 then               -- after 82 us the wire has not been set to 1 -> PE_start
            report "PE in reading0, 1 lasts more than 80us";
            PE_start <= '1';                  -- Protocol error
            state := WAITING;
          else                                -- default case 
            s_reset_count_start <= '0';       -- to make the reset lasts one clock cycle
          end if;
        elsif state=READING1 then             -- state in which the sensor should set the wire on 1 for 80us
          if data_in='0' then                 -- end of state READING1, the wire has been set to 0
            if 78 <= count and count <= 82 then -- data_in should be set to 1 for 80 us
              start_read <= '1';              -- we start reading the message sent by the sensor
            else 
              PE_start <= '1';                      -- Protocol error
            end if;
            state := WAITING;                 -- move to WAITING state in any case 
          elsif count > 82 then               -- if data_in is not reset to 0 before 82 us there is a PE_start
            report "PE in reading1";
            PE_start <= '1';
            state := WAITING;                 -- move to WAITING state in case of PE
          else                                -- Default case (data_in=1 and count < 82)
            s_reset_count_start <= '0';
          end if; 
        end if ;  -- end switch case on the states
      end if ;    -- end if reset
    end if ;      -- end if rising edge
  end process START;

  COUNTER: process(clk, s_reset_count_n)
  begin
    if clk'event and clk = '1' then
      if s_reset_count_n = '0' then
        count <= 0;
      elsif pulse = '1' then
        count <= count + 1;
      end if;
    end if; 
  end process COUNTER;


  PRINTER: process(data_40, SW0, SW1, SW2, SW3) -- TODO check with the implementation of read message if data_40 is a sensibility
    variable switches : std_ulogic_vector(2 downto 0);
  begin
    switches := SW0 & SW1 & SW2 ;
    if SW3 = '1' then
      LED(0) <= CE;
      LED(1) <= '0'; --TODO : busy bit
      LED(2) <= SW0;
      LED(3) <= PE;
    else
      case switches is
        when "111" => LED <= data_40(39 downto 36);
        when "110" => LED <= data_40(35 downto 32);
        when "101" => LED <= data_40(31 downto 28);
        when "100" => LED <= data_40(27 downto 24);
        when "011" => LED <= data_40(23 downto 20);
        when "010" => LED <= data_40(19 downto 16);
        when "001" => LED <= data_40(15 downto 12);
        when "000" => LED <= data_40(11 downto 8);
        when others => LED <= "0000";
      end case;
    end if;

  end process;

  --TODO: work the PE better (how long does the PE lasts ?)
  READ_BIT: process(clk) -- Process that will read one bit at a time
    variable state: states_read_bit := WAITING;
  begin
    if rising_edge(clk) then         -- Only on the rising edge of the clock
      if state=WAITING then          -- when the process is waiting
        if (start_read_bit='1') then -- when start_read_bit is set by read_message we change state and start counting
          reading_bit <= '1';        -- tell to other process that this process is reading a bit
          state := COUNTING0;        -- change the state to COUNTING0
          s_reset_count_read <= '1'; -- start to count
          PE_read <= '0';                 -- no protocol error at the beginning ...
          s_add_read_bit <= '0';     -- to make the reset only last on clock cycle
        else                         -- default case of the waiting state
          s_reset_count_read <= '0'; -- to make the reset only last one clock period
          reading_bit <= '0';        -- tell the other processes that the process is not reading
          s_add_read_bit <= '0';     -- to make the reset only last on clock cycle
        end if;
      elsif state=COUNTING0 then     -- state when the process the time elapses when data_in is 0
        s_reset_count_read <= '0';   -- to make the reset only last one clock period
        if data_in = '1' then        -- when data_in changes to 1 we check for count
          --report "Phase 1 count" & to_string(count);
          if (48 < count and count < 52) then    -- normal case count=50us
            report "want to start phase 2";
            state := COUNTING1;                  -- change the state to the one where we count the time elapse when data_in is 1
            s_reset_count_read <= '1';           -- start the counter
          else                                   -- protocol error if count!=50us
            PE_read <= '1';                           -- set the PE_read bit
            state := WAITING;                    -- in case of PE_read we return to WAITING state
          end if;
        elsif count > 52 then
          PE_read <= '1';
          state := WAITING;                      -- in any case we switch to WAITING state
        end if ;
      elsif state=COUNTING1 then                 -- state COUNTING1 is the state when data_in is 1
        s_reset_count_read <= '0';               -- to make the reset only last one clock period
        if data_in = '0' then                    -- when data_in changes to 0 we check for count
          if (24 < count and count < 30) then    -- if data_in is set to 1 for 26-28 us it is an 0
            report "It is a 0";
            bit_read <= '0';                     -- set the bit read to 1
            s_add_read_bit <= '1';               -- add the bit read to the 40 bits shift register
          elsif (68 < count and count < 72) then -- if data_in is set to 1 for 26-28 us it is an 0
            report "It is a 1";
            bit_read <= '1';                     -- set the bit read to 1
            s_add_read_bit <= '1';               -- add the bit read to the 40 bits shift register
          else                                   -- else there was a protocol error
            PE_read <= '1';
          end if;
          state := WAITING;                      -- in any case we switch to WAITING state
        elsif count > 72 then
          PE_read <= '1';
          state := WAITING;                      -- in any case we switch to WAITING state
        end if;
      end if;
    end if;
  end process READ_BIT;

  READ_MESSAGE: process(clk)
    variable bit_index: integer := 0;
  begin
    if rising_edge(clk) then          -- Only on the rising edge of the clock
      if start_read = '1' then        -- want the process is called, we start reading the message
        reading_message <= '1';       -- signal that tells the other processes that we are reading a message
        start_read_bit <= '1';        -- start the process that will read a bit of the message
        bit_index := bit_index + 1;   -- increments the number of bits of the message read
      elsif reading_message = '1' then  -- it is reading a message
        if s_add_read_bit = '1' then -- the proccess reading a bit has finished reading the previous bit
          if bit_index < 39 then        -- if there are still some bits to read
            start_read_bit <= '1';      -- start the process that will read a bit of the message
            bit_index := bit_index + 1; -- increments the number of bits of the message read
          elsif bit_index = 39 then     -- this is the last bit to read !
            start_read_bit <= '1';      -- start the process that will read a bit of the message
            bit_index := 0;             -- we reset the number of bits read
            reading_message <= '0';     -- signal that tells that we have finished reading
          end if;
        else                            -- read bit process has not finished reading the bit
          start_read_bit <= '0';
        end if;
      elsif PE_read = '1' then        -- stop reading message in case of PE
        reading_message <= '0';
      else                            -- default case when the process is waiting
        start_read_bit <= '0';        -- to make the start_read_bit lasts one clock cycle
      end if;
    end if;
  end process READ_MESSAGE;

  UPDATE_DATA: process(reading_message)
  begin
    if (reading_message='0') then 
      data_40 <= do;
    end if;
  end process UPDATE_DATA;

  CHECK_CHECKSUM : process(data_40)
      variable computed_checksum : std_ulogic_vector(7 downto 0);
  begin
      computed_checksum := std_ulogic_vector(unsigned(data_40(39 downto 32)) + unsigned(data_40(31 downto 24)) + unsigned(data_40(23 downto 16)) + unsigned(data_40(15 downto 8))) ;
      if computed_checksum /= data_40(7 downto 0) then
          CE <= '1';
      else
          CE <= '0';
      end if;
  end process;



end architecture rtl;
