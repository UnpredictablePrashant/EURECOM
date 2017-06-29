library IEEE;
use IEEE.std_logic_1164.all;

entity lb is
        generic(
            freq : positive range 1 to 1000;
            timeout : positive range 1 to 1000000
        );

        port(
                clk : in std_ulogic;
                areset : in std_ulogic;
                led : out std_ulogic_vector(3 downto 0)
            );

    end lb;

architecture arc of lb is
    signal sresetn : std_ulogic;
    signal pulse : std_ulogic;
    signal di : std_ulogic;

    signal di_ini : std_ulogic;
    signal led_local : std_ulogic_vector(3 downto 0);
 

begin

    led <= led_local;
    di <= led_local(0) or (di_ini and pulse);

    sr0 : entity work.sr(arc)
    port map(
        clk => clk,
        sresetn => sresetn,
        shift => pulse,
        di => di,
        do => led_local
        );
    timer0 : entity work.timer(arc)
    generic map(
        freq => freq,
        timeout => timeout
    )
    port map( 
        clk => clk,
        sresetn => sresetn,
        pulse => pulse

        );

    ARESET_TO_SRESETN : process(clk)
    variable reset_inter : std_ulogic;
    begin
        if clk'event and clk='1' then
            sresetn <= reset_inter ;
            reset_inter := not areset;
        end if;
    end process; 

   -- COUNT3_PROCESS : process(pulse)
   -- begin
     --   if pulse = '1' then
     --       if count3 = 3 then
       --         count3 <= 0;
     --       else
     --           count3 <= count3 + 1 ;
     --       end if;
     --   end if;
 --   end process;

  --  ROTATE1 : process(count3)
  --  begin
  --      if count3 = 0 then
  --          di <= '1';
  --      else
  --          di <= '0';
  --      end if;
  --  end process;

    ASSIGN_DI : process(clk)
    begin
        if clk'event and clk = '1' then
            if sresetn = '0' then
                di_ini <= '1';
            elsif pulse = '1' then 
                di_ini <= '0';
            end if;
        end if; 
    end process;

end arc;



