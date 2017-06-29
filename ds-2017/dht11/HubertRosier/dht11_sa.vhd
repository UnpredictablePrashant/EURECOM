-- DTH11 controller wrapper, standalone version
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dht11_sa is
    generic(
    freq:    positive range 1 to 1000 -- Clock frequency (MHz)
);
port(
        clk:      in  std_ulogic;
        rst:      in  std_ulogic; -- Active high synchronous reset
        btn:      in  std_ulogic;
        sw:       in  std_ulogic_vector(3 downto 0); -- Slide switches
        data_in:  in  std_ulogic;
        data_drv: out std_ulogic;
        led:      out std_ulogic_vector(3 downto 0) -- LEDs
    );
end entity dht11_sa;


architecture rtl of dht11_sa is
    signal srstn: std_ulogic;
    signal start: std_ulogic;
    signal pe:    std_ulogic;
    signal b:     std_ulogic;
    signal do:    std_ulogic_vector(39 downto 0);
    signal CE :   std_ulogic; -- Set when checksum error

begin
    srstn <= not rst;
    deb: entity work.debouncer(rtl)
    port map(
                clk   => clk,
                srstn => srstn,
                d     => btn,
                q     => open,
                r     => start,
                f     => open,
                a     => open
            );
    u0: entity work.dht11_ctrl(rtl)
    generic map(
                   freq => freq
               )
    port map(
                clk      => clk,
                srstn    => srstn,
                start    => start,
                data_in  => data_in,
                data_drv => data_drv,
                pe       => pe,
                b        => b,
                do       => do
            );

    PRINTER: process(do, sw, pe, b, CE)
    begin
        if sw(3) = '1' then
            led(0) <= CE;
            led(1) <= b;
            led(2) <= sw(0);
            led(3) <= pe;
        else
            case sw(2 downto 0) is
                when "111" => led <= do(39 downto 36);
                when "011" => led <= do(35 downto 32);
                when "101" => led <= do(31 downto 28);
                when "001" => led <= do(27 downto 24);
                when "110" => led <= do(23 downto 20);
                when "010" => led <= do(19 downto 16);
                when "100" => led <= do(15 downto 12);
                when "000" => led <= do(11 downto 8);
                when others => led <= "0000";
            end case;
        end if;
    end process;

    CHECK_CHECKSUM : process(do)
        variable computed_checksum : std_ulogic_vector(7 downto 0);
    begin
        computed_checksum := std_ulogic_vector(unsigned(do(39 downto 32)) + unsigned(do(31 downto 24)) + unsigned(do(23 downto 16)) + unsigned(do(15 downto 8))) ;
        if computed_checksum /= do(7 downto 0) then
            CE <= '1';
        else
            CE <= '0';
        end if;
    end process;

end architecture rtl;
