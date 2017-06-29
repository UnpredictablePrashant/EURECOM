library ieee;
use ieee.std_logic_1164.all;

entity display is
  Generic ( 
	     N: positive range 1 to 16;
	     M: positive range 1 to 256;
	     T: positive range 1 to 16
          );
  port(
	sw: in std_ulogic_vector(N-1 downto 0);
	data: in std_ulogic_vector(M-1 downto 0);
	led: out std_ulogic_vector(T-1 downto 0);
	parity_check: in std_ulogic;
	proto_err: in std_ulogic;
	busy: in std_ulogic
  );
end entity display;

architecture rtl of display is
begin

  process(data, sw, busy,proto_err,parity_check)
  begin
	
	if sw(3) = '1' then
	   led(3) <= sw(0);
	   led(2) <= proto_err;
	   led(1) <= busy;
	   led(0) <= parity_check;
	else
		if sw(0) = '0' then
		--visualize RH values
			case sw(2 downto 1) is
				when "00" => --show the most significant nibble of integralRH
					led(3 downto 0) <= data(15 downto 12);
				when "01" => --show the less significant nibble of integralRH
					led(3 downto 0) <= data(11 downto 8);
				when "10" => --show the most significant nibble of decimalRH
					led(3 downto 0) <= data(7 downto 4);
				when "11" => --show the less significant nibble of decimalRH
					led(3 downto 0) <= data(3 downto 0);
				when others =>  
					led(3 downto 0) <= (others => '0');
			end case;
		else 
		--visualize T values
			case sw(2 downto 1) is
				when "00" => --show the most significant nibble of integralT
					led(3 downto 0) <= data(31 downto 28);
				when "01" => --show the less significant nibble of integralT
					led(3 downto 0) <= data(27 downto 24);
				when "10" => --show the most significant nibble of decimalT
					led(3 downto 0) <= data(23 downto 20);
				when "11" => --show the less significant nibble of decimalT
					led(3 downto 0) <= data(19 downto 16);
				when others =>  
					led(3 downto 0) <= (others => '0');
			end case;
		end if;
	end if;
  end process;

end architecture rtl;
