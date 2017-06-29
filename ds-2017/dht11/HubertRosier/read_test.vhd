library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity read_test is
  generic(
           freq: integer := 125 -- 125 MHz 
         );
end entity read_test;

architecture arc of read_test is 
  signal CLK: std_ulogic;
  signal PE: std_ulogic;
  signal pulse: std_ulogic;
  signal data_in:  std_ulogic;
  signal s_reset_count_n : std_ulogic; -- to reset the counter process
  signal count : integer; -- contains the number of us elapsed since the last reset of the counter
  signal start_read_bit : std_ulogic; -- to start the reading of one bit of the message
  signal start_read: std_ulogic; -- to start the reading of one bit of the message
  signal a_start_read: std_ulogic; -- to start the reading of one bit of the message
  signal bit_read : std_ulogic; -- contains the last bit read by the interface
  signal reading_bit : std_ulogic; -- tell if the controller is receiving one bit
  signal reading_message: std_ulogic; -- tell if the controller is receiving one bit
  signal s_reset_count_read : std_ulogic; -- to reset the counter

  -- Signal used to store data --
  signal data_40: std_ulogic_vector(39 downto 0);  -- Vector that contains the data received. The value is good is readings_bits is 0.
  signal a_add_read_bit : std_ulogic ; -- asynchronous signal that tell that a bit has been read and needs to be saved
  signal s_add_read_bit : std_ulogic; -- synchronous signal that will save in the register the value of the read bit
  signal s_reset_data40_n: std_ulogic; -- to reset the value of the data40
  type states_read_bit is (WAITING,COUNTING0,COUNTING1);


begin
  timer: entity work.timer(arc)
  generic map(
               freq => freq,
               timeout => 1
             )
  port map(
            clk => clk,
            sresetn => s_reset_count_n,
            pulse => pulse
          );
  shift_reg: entity work.sr(arc)
  port map (
             clk => clk,
             sresetn => s_reset_data40_n,
             di => bit_read,
             do => data_40,
             shift => s_add_read_bit
           );

  CLK_GEN : process
    variable half_period: time := integer(1000 / freq) * 0.5 ns; -- to make the clock run at the right frequency
  begin
    CLK <= '0';
    wait for half_period ;
    CLK <= '1';
    wait for half_period ;
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
          PE <= '0';                 -- no protocol error at the beginning ...
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
            state := COUNTING1;                  -- change the state to the one where we count the time elapse when data_in is 1
            s_reset_count_read <= '1';           -- start the counter
          else                                   -- protocol error if count!=50us
            PE <= '1';                           -- set the PE bit
            state := WAITING;                    -- in case of PE we return to WAITING state
          end if;
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
            PE <= '1';
          end if;
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
        report "Start bit_index:" & to_string(bit_index);
        start_read_bit <= '1';        -- start the process that will read a bit of the message
        bit_index := bit_index + 1;   -- increments the number of bits of the message read
      elsif reading_message = '1' then  -- it is reading a message
        if s_add_read_bit = '1' then -- the proccess reading a bit has finished reading the previous bit
          if bit_index < 39 then        -- if there are still some bits to read
            report "bit_index:" & to_string(bit_index);
            start_read_bit <= '1';      -- start the process that will read a bit of the message
            bit_index := bit_index + 1; -- increments the number of bits of the message read
          elsif bit_index = 39 then     -- this is the last bit to read !
            report "End bit_index:" & to_string(bit_index);
            start_read_bit <= '1';      -- start the process that will read a bit of the message
            bit_index := 0;             -- we reset the number of bits read
            reading_message <= '0';     -- signal that tells that we have finished reading
          end if;
        else                            -- read bit process has not finished reading the bit
          start_read_bit <= '0';
        end if;
      else                            -- default case when the process is waiting or when read_bit is running
        start_read_bit <= '0';        -- to make the start_read_bit lasts one clock cycle
      end if;
    end if;
  end process READ_MESSAGE;

  COUNTER: process(clk)
  begin
    if clk'event and clk = '1' then
      if s_reset_count_n = '0' then
        count <= 0;
      elsif pulse = '1' then
        count <= count + 1;
      end if;
    end if;
  end process COUNTER;


  s_reset_count_n <= not s_reset_count_read;

  SIM: process
  begin
    a_start_read <= '0';
    wait for 40 us;
    a_start_read <= '1'; -- start the acquisition
    for i in 0 to 39 loop  -- Send '01010101010101010'
      data_in <= '0';   -- sending 0
      wait for 50 us;
      data_in <= '1';
      wait for 27 us;   -- 0 sent
      data_in <= '0';   -- sending 1
      wait for 50 us;
      data_in <= '1';
      wait for 70 us;   -- 1 sent
    end loop;

    a_start_read <= '0';
    wait for 40 us;
    a_start_read <= '1';
    for i in 0 to 19 loop -- send '01100110011001100...'
      data_in <= '0';   -- sending 0
      wait for 50 us;
      data_in <= '1';
      wait for 27 us;   -- 0 sent
      data_in <= '0';   -- sending 1
      wait for 50 us;
      data_in <= '1';
      wait for 70 us;   -- 1 sent
      data_in <= '0';   -- sending 1
      wait for 50 us;
      data_in <= '1';
      wait for 70 us;   -- 1 sent
      data_in <= '0';   -- sending 0
      wait for 50 us;
      data_in <= '1';
      wait for 27 us;   -- 0 sent
    end loop;
    assert false report "Simulation Finished" severity failure; -- To end the simulation
  end process SIM;

  process (clk,a_start_read) -- to make the start read message signal only lasts one clock cycle
    variable tmp : std_ulogic := '0';
  begin 
    if rising_edge(clk) then 
      if tmp = '0' and a_start_read='1' then 
        start_read <= '1';
        s_reset_data40_n <= '0';
        tmp := '1';
      elsif a_start_read='0' then
        tmp := '0';
      else
        start_read <= '0';
        s_reset_data40_n <= '1';
      end if ;
    end if ;
  end process ;

end architecture arc;
