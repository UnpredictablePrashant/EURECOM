package env is

	procedure stop;
	function rising_edge(signal s: in bit) return boolean;

end package env;

package body env is

	procedure stop is
	begin
		assert false report "This is the end" severity failure;
	end procedure stop;

	function rising_edge(signal s: in bit) return boolean is
	begin
		return s'event and s = '1';
	end function rising_edge;

end package body env;
