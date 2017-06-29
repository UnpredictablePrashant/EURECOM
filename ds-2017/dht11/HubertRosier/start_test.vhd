library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity start_test is
  generic(
           freq: integer := 125 -- 125 MHz 
         );
end entity start_test;

architecture arc of start_test is 
  signal CLK: std_ulogic;
  signal data_in:  std_ulogic;
  signal data:  std_ulogic;
  signal data_drv: std_ulogic;
  signal busy: std_ulogic;                 -- the signal that tells if the sensor is sending data or if the 1s delay is passed or not
  signal s_reset_count_n : std_ulogic;     -- to reset the counter process
  signal count : integer := 0;                  -- contains the number of us elapsed since the last reset of the counter
  signal pulse : std_ulogic;               --
  signal PE_start : std_ulogic;                  -- LED 3, protocol error 
  signal s_BTN : std_ulogic;               -- synchronous sigal that lasts one cycle after the button has been pressed

  -- Signal used to start an acquisition
  type states_start is (WAITING,SENDING0,SENDING1,READING0,READING1); -- states of the process START
  signal s_reset_count_start : std_ulogic;                                    -- to reset the counter from the process START

  -- Signal used to read --
  type states_read_bit is (WAITING,COUNTING0,COUNTING1);
  signal start_read : std_ulogic;          -- to start receiving the sensor's message
  signal start_read_bit : std_ulogic;      -- to start the reading of one bit of the message
  signal bit_read : std_ulogic;            -- contains the last bit read by the interface
  signal reading_message : std_ulogic;     -- signal that tells if the controller is receiving data
  signal reading_bit : std_ulogic;         -- tell if the controller is receiving one bit
  signal s_reset_count_read : std_ulogic;  -- to reset the counter

  -- Signal used to store data --
  signal data_40: std_ulogic_vector(39 downto 0); -- Vector that contains the data received. The value is good is readings_bits is 0.
  signal s_add_read_bit : std_ulogic;             -- synchronous signal that will save in the register the value of the read bit 
  signal s_reset_data40_n: std_ulogic;            -- to reset the value of the data40

  signal CE : std_ulogic; -- Set when checksum error

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

  START: process(clk)
    variable state: states_start := WAITING;
    variable start_sending0: std_ulogic;
  begin
    if rising_edge(clk) then 
      s_reset_count_start <= '0';
      if state=WAITING then        -- state in which the process wait for the button to be pressed
        if busy='0' and s_BTN='1' then         -- we can start asking for data after 1s 
          report "Sending0";
          state := SENDING0;          -- switch to state SENDING0 
          start_sending0 := '1';
          data_drv <= '1';            -- take the control of the connection
          data <= '0';                -- set the connection to 0
          s_reset_count_start <= '1'; -- reset the counter
        else                          -- default case in WAITING state
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
            report "reading1";
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
      end if ;
    end if ;
  end process START;


  process(clk)
    variable tmp: std_ulogic := '0';
  begin
    if rising_edge(clk) then 
      if (tmp='1') then 
        busy <= '0';
      elsif (count>=10) then
        tmp := '1';
        report "Ready to start";
      else 
        busy <= '1';
      end if;
    end if;
  end process;

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

  s_reset_count_n <= not s_reset_count_start;

  SIM: process
  begin
    s_BTN <= '0';
    wait until rising_edge(clk);
    s_BTN <= '1';
    wait until rising_edge(clk);
    s_BTN <= '0';
    wait until rising_edge(clk);
    wait for 20 us;
    s_BTN <= '0';
    wait until rising_edge(clk);
    s_BTN <= '1';
    wait until rising_edge(clk);
    s_BTN <= '0';
    wait until rising_edge(clk);
    wait until data_drv ='0';
    data_in <= '1';
    wait for 32 us;
    data_in <= '0';
    wait for 80 us;
    data_in <= '1';
    wait for 80 us;
    data_in <= '0';
    wait for 10 us;
    assert false report "Simulation Finished" severity failure; -- To end the simulation
  end process;

end architecture arc;
  --  SIM: process
  --  begin
  --    a_start_read <= '0';
  --    wait for 40 us;
  --    a_start_read <= '1'; -- start the acquisition
  --    for i in 0 to 39 loop  -- Send '01010101010101010'
  --      data_in <= '0';   -- sending 0
  --      wait for 50 us;
  --      data_in <= '1';
  --      wait for 27 us;   -- 0 sent
  --      data_in <= '0';   -- sending 1
  --      wait for 50 us;
  --      data_in <= '1';
  --      wait for 70 us;   -- 1 sent
  --    end loop;

  --    a_start_read <= '0';
  --    wait for 40 us;
  --    a_start_read <= '1';
  --    for i in 0 to 19 loop -- send '01100110011001100...'
  --      data_in <= '0';   -- sending 0
  --      wait for 50 us;
  --      data_in <= '1';
  --      wait for 27 us;   -- 0 sent
  --      data_in <= '0';   -- sending 1
  --      wait for 50 us;
  --      data_in <= '1';
  --      wait for 70 us;   -- 1 sent
  --      data_in <= '0';   -- sending 1
  --      wait for 50 us;
  --      data_in <= '1';
  --      wait for 70 us;   -- 1 sent
  --      data_in <= '0';   -- sending 0
  --      wait for 50 us;
  --      data_in <= '1';
  --      wait for 27 us;   -- 0 sent
  --    end loop;
  --    assert false report "Simulation Finished" severity failure; -- To end the simulation
  --  end process SIM;

  --  process (clk,a_start_read) -- to make the start read message signal only lasts one clock cycle
  --    variable tmp : std_ulogic := '0';
  --  begin 
  --    if rising_edge(clk) then 
  --      if tmp = '0' and a_start_read='1' then 
  --        start_read <= '1';
  --        s_reset_data40_n <= '0';
  --        tmp := '1';
  --      elsif a_start_read='0' then
  --        tmp := '0';
  --      else
  --        start_read <= '0';
  --        s_reset_data40_n <= '1';
  --      end if ;
  --    end if ;
  --  end process ;
