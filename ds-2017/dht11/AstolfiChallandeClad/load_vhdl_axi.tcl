# Adapt the list of source files to your own project. List *only* the
# synthesizable files. Do *not* list simulation source files.

set source_files { 
	dht11_pkg_syn.vhd
	debouncer.vhd
	timer.vhd
	sr.vhd
	dht11_ctrl.vhd
	axi_pkg.vhd
	dht11_axi.vhd
	dht11_axi_top.vhd
	
}

foreach f $source_files {
	add_files $rootdir/$f
}

