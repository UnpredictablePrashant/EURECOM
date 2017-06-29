library IEEE; 
--use ieee.numeric_std.all;
--use ieee.std_ulogic.all;
use ieee.std_logic_1164.all;


-- Declare inputs and outputs
entity datamux is
  port(
    sw:     in std_ulogic_vector(2 downto 0);
    d_in:   in std_ulogic_vector(31 downto 0);
    d_out:  out std_ulogic_vector(3 downto 0)
  );
end entity datamux;

architecture arc of datamux is 
    signal local_sw : std_ulogic_vector(2 downto 0);
begin
    process (sw, d_in, local_sw)
    begin 
        local_sw <= sw(2 downto 0);

--ASSUMPTION: SIPO shift register shifts LEFT, so that higher order bit, which is sent first, stays the higher order bit. 

--Data consists of decimal and integral parts. A complete d_in transmission is 40bit, and the sensor sends higher d_in bit first.
--Data format: 8bit integral RH d_in + 8bit decimal RH d_in + 8bit integral T d_in + 8bit decimal T d_in + 8bit check sum. 
--1 switch to select the d_in to display : temperature or humidity (SW0). When the switch is set to 1, we read the humidity level, when it is 0, we read the temperature.
--2 switches to select 4 bits out of the 16 bits (4 bits nibbles) of the d_in to display (SW1 and SW2).
--When SW1=0 and SW2=0, we display the 4 less significant bits of the d_in.
--When SW1=0 and SW2=1, we display the 5th to 8th less significant bits.
--When SW1=1 and SW2=0, we display the 5th to 8th most significant bits.
--When SW1=1 and SW2=1, we display the 4 most significant bits of the d_in.
        case local_sw is
            when "000" => d_out <= d_in(3 downto 0);
            when "100" => d_out <= d_in(7 downto 4);
            when "010" => d_out <= d_in(11 downto 8);
            when "110" => d_out <= d_in(15 downto 12);
            when "001" => d_out <= d_in(19 downto 16);
            when "101" => d_out <= d_in(23 downto 20);
            when "011" => d_out <= d_in(27 downto 24);
            when "111" => d_out <= d_in(31 downto 28);
            when others => d_out <= "0000";
        end case; 
    end process;
end architecture arc;
