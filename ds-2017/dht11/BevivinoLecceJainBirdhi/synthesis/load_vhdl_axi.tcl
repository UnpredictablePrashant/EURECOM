# Adapt the list of source files to your own project. List *only* the
# synthesizable files. Do *not* list simulation source files.

set source_files { 
	checker.vhd
	checker_20_40.vhd
	checker_26_28.vhd
	global_checker.vhd
	checksum.vhd
	sampler2.vhd
	sr.vhd
	display.vhd
	counter.vhd
	counter_master.vhd
	datapath.vhd
	FSM.vhd
	dht11_pkg_syn.vhd
	debouncer.vhd
	dht11_ctrl.vhd
	axi_pkg.vhd
	dht11_axi.vhd
	dht11_axi_top.vhd
}

foreach f $source_files {
	add_files $rootdir/$f
}


