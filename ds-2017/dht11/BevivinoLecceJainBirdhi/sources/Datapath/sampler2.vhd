library ieee;
use ieee.std_logic_1164.all;

entity sampler2 is
 
  port(
	clk:		in std_ulogic;
	start_sampl:	in std_ulogic;
	serial_data_in:	in std_ulogic;
	rstsn:		in std_ulogic;
	meas_rdy:	out std_ulogic;
	sample_value:	out integer range 0 to 24000
  );
end entity sampler2;

architecture rtl of sampler2 is

  
	signal l:    std_ulogic;                -- local copy of output
	signal lp:   std_ulogic;                -- previous value of l
	signal a:    std_ulogic:='0';         
	signal tmp_clk: integer range 0 to 24000;
	signal rdy: std_ulogic;
	signal def_value: integer range 0 to 24000;

begin

  l <= (serial_data_in);
 
  process(clk)
  variable flag: integer := 0;
variable k: integer := 0;
  begin
    if rising_edge(clk) then
		if rstsn='0' then
			tmp_clk<=150;
			rdy<='0';
			flag:=0;
			a<='0';
			k:=0;
		else
			if k<150 then
				k:=k+1;
				lp <= serial_data_in;
			else
			
				if start_sampl = '1' or flag=1 or (start_sampl = '1' and flag=1) then
				   flag:=1;
				   if flag = 1 then
					if a='0' and rdy='0' then
						tmp_clk<=tmp_clk+1;
						a    <= lp xor l;
		       				lp   <= l;
					else
						rdy<='1';
						flag:=0;
						def_value<=tmp_clk;
					end if;
				    end if;
				end if; 
			end if; 
      		end if;
    end if;
  end process;

	sample_value<=def_value;
	meas_rdy<=rdy;

end architecture rtl;
