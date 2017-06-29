library ieee;
use ieee.std_logic_1164.all;

entity sr is
    port (
        clk:  in  std_ulogic;
        sresetn:  in  std_ulogic;
        shift:  in  std_ulogic;
        di:  in  std_ulogic;
        do:  out std_ulogic_vector(39 downto 0)
        );
end entity sr;

architecture arc of sr is 
  signal reg : std_ulogic_vector (39 downto 0);
begin
  -- do <= to_stdlogicvector(reg);
  do <= reg;
  process(clk)
  begin
    if clk'event and clk = '1' then
      if sresetn = '0' then 
        reg <= (others => '0');
      else
        if shift = '1' then
          reg(39 downto 1) <= reg (38 downto 0);
          reg(0) <= di;
        end if;
      end if ;
    end if ;
  end process;
end arc;
