entity accumulator is
  port(
    clk:   in  bit;
    a_rst: in  bit;
    s:     in  bit;
    a:     in  integer;
    b:     in  integer;
    q:     out integer
  );
end entity accumulator;

--this design can be optimized for VHDL-2008 leaving reg_q using
--only q and using rising_edge(clock) instead of clk'event and clk='1'

architecture rtl of accumulator is
  signal reg_q: integer;
  signal mux_q_adder_d: integer;
  signal adder_q_register_d: integer;
begin
  --Mux process
  mux_q_adder_d<=reg_q when s='0'else b;
  --Adder process
  adder_q_register_d<=a+mux_q_adder_d;  
  --Flip-flop
  FF: process(clk,a_rst)
  begin
    if(a_rst='1') then
        reg_q<=0;
    elsif(clk'event and clk='1') then
        reg_q<=adder_q_register_d;
    end if;   
  end process FF;
  q<=reg_q;
end architecture rtl;