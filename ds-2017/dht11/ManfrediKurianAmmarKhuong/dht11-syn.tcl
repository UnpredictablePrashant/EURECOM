#
# Copyright (C) Telecom ParisTech
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

set part "xc7z010clg400-1"
set board "digilentinc.com:zybo:part0:1.0"
set frequency 125
set timeout 50000
array set ios {
	"clk"		{ "L16" "LVCMOS33" }
	"rst" 		{ "R18" "LVCMOS33" }
	"btn" 		{ "Y16" "LVCMOS33" } 
	"sw[0]"        	{ "G15" "LVCMOS33" }
	"sw[1]"        	{ "P15" "LVCMOS33" }
	"sw[2]"        	{ "W13" "LVCMOS33" }
	"sw[3]"        	{ "T16" "LVCMOS33" }
	"data"        	{ "V12" "LVCMOS33" }
	"led[0]"        { "M14" "LVCMOS33" }
	"led[1]"        { "M15" "LVCMOS33" }
	"led[2]"        { "G14" "LVCMOS33" }
	"led[3]"        { "D18" "LVCMOS33" }
}

puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "Frequency: $frequency MHz"
puts "Timeout: $timeout µs"
puts "*********************************************"

########################
# Create DHT11 project #
########################
create_project -part $part -force dht11_sa_top dht11_sa_top
add_files 8to4mux.vhd checksum.vhd datamux.vhd debouncer.vhd fsm.vhd sipo.vhd syncdata.vhd timer.vhd dht11_ctrl.vhd dht11_pkg.vhd dht11_sa.vhd dht11_sa_top.vhd
import_files -force -norecurse
ipx::package_project -root_dir dht11_sa_top -vendor www.telecom-paristech.fr -library DHT11 -force dht11_sa_top
close_project

############################
## Create top level design #
############################
set top top
create_project -part $part -force $top .
set_property board_part $board [current_project]
set_property ip_repo_paths { ./dht11_sa_top } [current_fileset]
update_ip_catalog
create_bd_design "$top"
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
set dht11_sa_top [create_bd_cell -type ip -vlnv [get_ipdefs *www.telecom-paristech.fr:DHT11:dht11_sa_top:*] dht11_sa_top]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {0}] $ps7
set_property -dict [list CONFIG.freq $frequency] $dht11_sa_top

# Interconnections
# Primary IOs
create_bd_port -dir I -type clk clk
connect_bd_net [get_bd_pins /dht11_sa_top/clk] [get_bd_ports clk]
create_bd_port -dir I -type rst rst
connect_bd_net [get_bd_pins /dht11_sa_top/rst] [get_bd_ports rst]
create_bd_port -dir I btn
connect_bd_net [get_bd_pins /dht11_sa_top/btn] [get_bd_ports btn]
create_bd_port -dir IO data
connect_bd_net [get_bd_pins /dht11_sa_top/data] [get_bd_ports data]
create_bd_port -dir I -from 3 -to 0 sw
connect_bd_net [get_bd_pins /dht11_sa_top/sw] [get_bd_ports sw]
create_bd_port -dir O -type data -from 3 -to 0 led
connect_bd_net [get_bd_pins /dht11_sa_top/led] [get_bd_ports led]

# Synthesis flow
validate_bd_design
set files [get_files *$top.bd]
generate_target all $files
add_files -norecurse -force [make_wrapper -files $files -top]
save_bd_design
set run [get_runs synth*]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none $run
launch_runs $run
wait_on_run $run
open_run $run

# IOs
foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

# Clocks and timing
create_clock -name clk -period [expr 1000.0 / $frequency] [get_ports clk]
set_false_path -from clk -to [get_ports led[*]]
set_false_path -from [get_ports rst] -to clk

# Implementation
save_constraints
set run [get_runs impl*]
reset_run $run
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true $run
launch_runs -to_step write_bitstream $run
wait_on_run $run

# Messages
set rundir $top.runs/$run
puts ""
puts "\[VIVADO\]: done"
puts "  bitstream in $rundir/${top}_wrapper.bit"
puts "  resource utilization report in $rundir/${top}_wrapper_utilization_placed.rpt"
puts "  timing report in $rundir/${top}_wrapper_timing_summary_routed.rpt"
