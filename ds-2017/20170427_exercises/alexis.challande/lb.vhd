library IEEE;
use IEEE.std_logic_1164.all;

entity lb is
	generic(
        freq: positive range 1 to 1000;
        timeout: positive range 1 to 1000000
    );
    port(
    	clk:	 in std_ulogic;
        areset:  in   std_ulogic;
        led:     out   std_ulogic_vector(3 downto 0)
    );

end lb;

architecture arc of lb is
	signal sresetn:     std_ulogic;
	signal di:          std_ulogic;
	signal led_local:   std_ulogic_vector(3 downto 0);
    signal pulse:       std_ulogic;
    signal firstDi:     std_ulogic;
begin

	timer: entity work.timer(arc)
		generic map(
			freq    => freq,
			timeout => timeout
		)
		port map(
			clk     => clk,
			sresetn => sresetn,
			pulse   => pulse
		);
    
	sr: entity work.sr(arc)
		port map(
			clk     => clk,
			sresetn => sresetn,
			shift   => pulse,
			di      => di,
			do      => led_local
		);
        
    led <= led_local;
    di <= led_local(0) or (firstDi and pulse); 

    process(clk)
        variable reg: std_ulogic;
    begin
        if rising_edge(clk) then
            sresetn <= reg;
            reg := not areset;
        end if;
    end process;

    process (clk, areset)
        variable reg: std_ulogic_vector(1 downto 0);
    begin
        if rising_edge(clk)
        then
            if sresetn = '0' then
                firstDi <= '1';
            else
                firstDi <= '0';
            end if;
        end if;
    end process;

end arc;
