dht11_axi.vhd: axi_pkg.vhd dht11_ctrl.vhd

dht11_ctrl.vhd: dht11_pkg.vhd sipo.vhd timer.vhd fsm.vhd syncdata.vhd 

dht11_ctrl_sim.vhd: dht11_pkg.vhd dht11_ctrl.vhd

dht11_sa.vhd: debouncer.vhd checksum.vhd 8to4mux.vhd datamux.vhd dht11_ctrl.vhd

dht11_sa_top.vhd: dht11_sa.vhd

dht11_sa_sim.vhd: debouncer.vhd dht11_pkg.vhd dht11_sa.vhd dht11_ctrl_sim.vhd

8to4mux_tb.vhd: 8to4mux.vhd
sipo_sim.vhd: sipo.vhd
timer_sim.vhd: timer.vhd
datamux_tb.vhd: datamux.vhd
fsm_sim.vhd: fsm.vhd
checksum_sim.vhd: checksum.vhd
