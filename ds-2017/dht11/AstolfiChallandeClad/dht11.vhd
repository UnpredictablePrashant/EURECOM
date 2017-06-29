library ieee;
use ieee.std_logic_1164.all;

use work.dht11_pkg.all;

entity dht11 is
	port(
		cmd:      in    error_type;
		data_ref: out   std_ulogic_vector(39 downto 0);
		valid:    out   boolean;
		data:     inout std_logic
	);
end entity dht11;

architecture beh of dht11 is

	signal data_in: x01;

begin

	data_in <= to_x01(data);

	process
	begin
		wait for 1 ns;
		loop
			assert data_in /= 'X' report "Invalid data value: " & to_string(data) severity failure;
			wait on data_in;
		end loop;
	end process;

	process
		variable t: time;
		variable d: std_ulogic_vector(39 downto 0);
	begin
		data  <= 'Z';
		valid <= false;
		wait for 1 sec;
		loop
			if data_in /= '0' then
				wait until data_in = '0';
			end if;
			t := now;
			valid <= false;
			wait until data_in = '1';
			assert now - t >= 18 ms
			report "Invalid start signal duration: " & to_string(now - t)
			severity failure;
			rnd_duration(cmd, 20.0 us, 40.0 us, t);
			wait for t;
			data <= '0';
			rnd_duration(cmd, 80.0 us, 80.0 us, t);
			wait for t;
			data <= 'Z';
			rnd_duration(cmd, 80.0 us, 80.0 us, t);
			wait for t;
			rnd_data(cmd, d);
			data_ref <= d;
			for i in 39 downto 0 loop
				data <= '0';
				rnd_duration(cmd, 50.0 us, 50.0 us, t);
				wait for t;
				data <= 'Z';
				if d(i) = '0' then
					rnd_duration(cmd, 26.0 us, 28.0 us, t);
				else
					rnd_duration(cmd, 70.0 us, 70.0 us, t);
				end if;
				wait for t;
			end loop;
			data <= '0';
			rnd_duration(cmd, 50.0 us, 50.0 us, t);
			wait for t;
			data  <= 'Z';
			valid <= true;
		end loop;
	end process;

end architecture beh;
