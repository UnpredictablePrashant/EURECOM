library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dht11_top is
    generic(
        freq:    positive range 1 to 20    := 1 --20ns frequency
    );
    port (
        data:       inout std_logic;
           led:        out std_ulogic_vector(3 downto 0);
           switch0:    in std_ulogic;
           switch1:    in std_ulogic;
           switch2:    in std_ulogic;
           switch3:    in std_ulogic;
        push:       in std_ulogic
    );
end entity dht11_top;


architecture rtl of dht11_top is
    type ST is (IDLE, INIT, STORE, DISPLAY, READ);
    signal state, next_state : ST;

    signal dataIn, dataOut, sendData : std_ulogic;
    signal sresetn : std_ulogic := '1';
    signal PE : std_ulogic;

    signal clk : std_ulogic;

    signal endOfRead : std_ulogic;
    signal endOfBitRead : std_ulogic;

    signal currentSwitches : std_ulogic_vector(3 downto 0);


    function toInt(vector:std_ulogic_vector) return integer is
    begin
        return to_integer(unsigned(vector));
    end function;

    function toTinyInt(currentBit:std_ulogic) return integer is
    begin
        if currentBit = '1' then
            return 1;
        else
            return 0;
        end if;
    end function;

begin

    P1 : process (clk, sresetn)
    begin
        if rising_edge(clk) then
            state <= next_state;
        end if;
    end process P1;

    -- Do the work
    P2 : process
        variable started : std_ulogic;
        variable value : std_ulogic_vector (39 downto 0);

        variable index,offset : integer range 0 to 39;

        variable bitRead : std_ulogic;

        variable errorMargin : integer := 5;
        variable count : integer;

        variable readStarted: std_ulogic := '0';
        variable checkSumError : std_ulogic := '0';

        variable temp : integer;
    begin
        wait on state;
        case state is
            when INIT =>
                led <= (others => '1');
                wait for 500 ms;
                led <= (others => '0');
                wait for 500 ms;
                led <= (others => '1');
                wait for 500 ms;
                led <= (others => '0');
                wait for 500 ms;
                led <= (others => '1');
                wait for 500 ms;
                led <= (others => '0');
                wait for 500 ms;
                started := '1'; --means that dht is ready / has started

            when IDLE =>
                index := 0;
                readStarted := '0';
                checkSumError := '0';

                endOfRead <= '0';
                endOfBitRead <= '0';
                PE <= '0';

            when STORE =>
                if (switch3 = '0') then
                    value(index) := bitRead;
                    index := index+1;
                end if;

                if (index = 40) then
                    temp := toInt(value(7 downto 0))
                            + toInt(value(15 downto 8))
                            + toInt(value(23 downto 16))
                            + toInt(value(31 downto 24));
                    if (toInt(value(39 downto 32)) /= temp mod 256) then
                            checkSumError := '1';
                    end if;
                    endOfRead <= '1';
                end if;

            when DISPLAY =>
                if currentSwitches(3) = '1' then
                    offset := (1-toTinyInt(currentSwitches(0))) * 16
                            + (1-toTinyInt(currentSwitches(1))) * 8
                            + (1-toTinyInt(currentSwitches(2))) * 4;
                    led <= value(offset+3 downto offset);
                else
                    --Error state
                    led <= (PE, currentSwitches(0), (not started or sendData), checkSumError);
                end if;

            when READ =>
                  -- First time
                if (readStarted = '0') then
                -- We send the signal we want to read
                    -- SEND 18+ms at GND
                    sendData <= '1';
                    dataOut <= '0';
                    wait for 19 ms;

                    -- SEND 20-40 us at VCC
                    dataOut <= '1';
                    wait for 30 us; --TODO CHECK IF ITS WORK

                    -- READ 80us GND
                    sendData <= '0';
                    wait for 40 us;
                    if (dataIn /= '0') then
                        PE <= '1';
                    end if;
                    wait for 40 us;

                    -- READ 80us VCC
                    wait for 40 us;
                    if (dataIn /= '1') then
                        PE <= '1';
                    end if;
                    wait for 40 us;
                    readStarted := '1';
                end if;

                -- We read the low value for 50us GND
                count := 0;
                sendData <= '1';
                while dataIn = '0' loop
                    count := count + 1;
                    wait for 1 us;
                end loop;
                if count > 50+errorMargin or count < 50-errorMargin then
                    PE <= '1';
                end if;

                count := 0;
                sendData <= '1';
                wait until dataIn = '1';
                while not dataIn'event loop
                    count := count + 1;
                    wait for 1 us;
                end loop;

                if count < 28+errorMargin and count > 26-errorMargin then
                    bitRead := '0';
                elsif count < 70+errorMargin and count > 70-errorMargin then
                    bitRead := '1';
                else
                    PE <= '1';
                end if;

                 endOfBitRead <= '1';

            when others =>
                next_state <= IDLE;
        end case;
    end process P2;

    data <= dataOut when sendData = '1';
    dataIn <= data when sendData = '0';

    -- Find next state
    P3 : process (state, push, switch0, switch1, switch2, switch3, endOfRead, endOfBitRead)
        variable newSwitches : std_ulogic_vector(3 downto 0);
    begin
        next_state <= state;
        case state is
            when INIT =>
                next_state <= IDLE;

            when IDLE =>
                newSwitches := (switch0, switch1, switch2, switch3);
                if (newSwitches /= currentSwitches) then
                    next_state <= DISPLAY;
                end if;

                if (push = '1') then
                    next_state <= STORE;
                end if;

                currentSwitches <= newSwitches;

            when STORE =>
                if (switch3 = '1' or endOfRead = '1' ) then
                    next_state <= DISPLAY;
                else
                    next_state <= READ;
                end if;

            when DISPLAY =>
                next_state <= IDLE;

            when READ =>
                if endOfBitRead = '1' then
                    next_state <= STORE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process P3;
end architecture rtl;
